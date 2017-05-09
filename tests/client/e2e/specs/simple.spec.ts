/* tslint:disable:no-unused-expression */

import { expect } from 'app/core/testing/chai-e2e.utils';

import { browser } from 'protractor';

import { UserBrowser } from 'e2e/helpers/user-browser.class';

import { SimplePage } from 'e2e/pages/simple.page';


describe('Application', () => {
    /**
     * The page that describe the test.
     *
     * @type {SimplePage}
     * @readonly
     * @constant
     * @default
     */
    const simplePage: SimplePage = new SimplePage(new UserBrowser('Jack', browser).connect());


    it('should have a title', () => {
        browser.get('/');
        expect(browser.getTitle()).to.eventually.equal('LumBoilerplate');
    });

    it('should have an "lb-app" element', () => {
        expect(simplePage.app).to.eventually.be.present;
    });
});
