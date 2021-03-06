//
//  AppDelegate.swift
//  Vocable AAC
//
//  Created by Duncan Lewis on 6/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Ensure that the persistent store has the current
        // default presets before presenting UI
        preparePersistentStore()

        application.isIdleTimerDisabled = true
        let window = HeadGazeWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    private func preparePersistentStore() {
        let container = NSPersistentContainer.shared
        if let url = container.persistentStoreCoordinator.persistentStores.first?.url?.absoluteString.removingPercentEncoding {
            print("NSPersistentStore URL: \(url)")
        }
        let context = container.viewContext
        deleteExistingPrescribedEntities(in: context)
        createPrescribedEntities(in: context)

        do {
            try context.save()
        } catch {
            assertionFailure("Core Data save failure: \(error)")
        }
    }

    private func deleteExistingPrescribedEntities(in context: NSManagedObjectContext) {

        let phraseRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        phraseRequest.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, false)
        let phraseResults = (try? context.fetch(phraseRequest)) ?? []
        for phrase in phraseResults {
            context.delete(phrase)
        }

        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
        categoryRequest.predicate = NSComparisonPredicate(\Category.isUserGenerated, .equalTo, false)
        let categoryResults = (try? context.fetch(categoryRequest)) ?? []
        for category in categoryResults {
            context.delete(category)
        }
    }

    private func createPrescribedEntities(in context: NSManagedObjectContext) {

        // Create entities that are provided implicitly
        for presetCategory in PresetCategory.allCases {

            let category = Category.fetchOrCreate(in: context, matching: presetCategory.description)
            category.creationDate = Date()
            category.name = presetCategory.description

            if presetCategory == .saved {
                category.isUserGenerated = true
            }

            for preset in TextPresets.presetsByCategory[presetCategory]?.reversed() ?? [] {
                let phrase = Phrase.fetchOrCreate(in: context, matching: preset)
                phrase.creationDate = Date()
                phrase.utterance = preset
                phrase.addToCategories(category)
                
            }
        }
    }
}
