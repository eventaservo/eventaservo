/// <reference types="cypress" />

import { faker } from '@faker-js/faker'

describe('Create events', () => {
  beforeEach(() => {
    cy.login()
    // Cypress starts out with a blank slate for each test
    // so we must tell it to visit our website with the `cy.visit()` command.
    // Since we want to visit the same URL at the start of all our tests,
    // we include it in our beforeEach function so that it runs before each test
  })

  it('with basic information', () => {
    cy.visit('/e/new')
    cy.get('#event_title').type(faker.commerce.product())
    cy.get('#event_description').type(faker.commerce.productName())
    cy.get('#event_enhavo').type(faker.commerce.productDescription())
    cy.get(':nth-child(2) > .btn').click()
    cy.get('#event_site').type('uea.org')
    cy.get('.button-submit').click()
    cy.contains('Evento sukcese kreita.')
  })

  it('deletes the first event from list', () => {
    cy.visit('/')
    cy.get(':nth-child(2) > .fc-list-item-title').click()
    cy.get('.buttons-footer > .btn-outline-primary').click()
    cy.get('.button-outline-red').click()
    cy.url().should('be.equal', `${Cypress.config().baseUrl}/`)
    cy.contains('Evento sukcese forigita')
  })
})
