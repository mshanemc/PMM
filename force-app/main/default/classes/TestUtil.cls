/*
 *
 *  * Copyright (c) 2020, salesforce.com, inc.
 *  * All rights reserved.
 *  * SPDX-License-Identifier: BSD-3-Clause
 *  * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 */

@IsTest
/**
 * Utility methods for test classes
 */
public with sharing class TestUtil {
    private static final Set<String> featureGateNames = new Set<String>{
        'ServiceDeliveriesToContact',
        'ServiceDeliveriesToService',
        'ServiceDeliveriesToServiceSession',
        'ServiceDeliveriesToProgramEngagement'
    };

    public static final String TEST_USER_EMAIL = 'temptestuser@caseplan.example.com';

    public static Integer counter {
        get {
            if (counter == null) {
                counter = 0;
            }
            counter++;

            return counter;
        }
        set;
    }

    public static Id mockId(SObjectType sObjType) {
        return mockIds(sObjType, 1)[0];
    }

    public static List<Id> mockIds(SObjectType sObjectType, Integer size) {
        String keyPrefix = sObjectType.getDescribe().getKeyPrefix();
        List<Id> ids = new List<Id>();

        for (Integer i = 0; i < size; i++) {
            Integer uniqueCounter = counter;
            ids.add(
                keyPrefix +
                '0'.repeat(12 - String.valueOf(uniqueCounter).length()) +
                uniqueCounter
            );
        }

        return ids;
    }

    public static User getTestUser() {
        // create user with no custom object permissions to test CRUD checks
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(
            Alias = 'standt',
            Email = TEST_USER_EMAIL,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Chicago',
            UserName = TEST_USER_EMAIL
        );
        return user;
    }

    public static void turnOffFeatureGates(Set<String> developerNames) {
        // TestStub turned off Feature Gates so we can insert Service Deliveries without triggers running
        List<FeatureGate__mdt> featureGates = new List<FeatureGate__mdt>();
        for (String name : featureGateNames) {
            featureGates.add(
                new FeatureGate__mdt(
                    DeveloperName = name,
                    IsActive__c = !developerNames.contains(name)
                )
            );
        }

        TestStub customMetadataSelectorStub = new StubBuilder(
                CustomMetadataSelector.class
            )
            .when('getAllFeatureGates')
            .called()
            .thenReturn(featureGates)
            .build();

        CustomMetadataSelector.instance = (CustomMetadataSelector) customMetadataSelectorStub.create();
    }

    public static void turnOffFeatureGates() {
        turnOffFeatureGates(featureGateNames);
    }
}
