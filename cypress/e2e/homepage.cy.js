/// <reference types="cypress" />

describe('Homepage', () => {
  beforeEach(() => {
    cy.login()
  })

  it('select and reset timezone', () => {
    cy.visit('https://localhost:3000/')
    cy.get('#select-timezone-link').click()
    cy.get('#select2-horzono-container').click()
    cy.wait(500)
    cy.get('.select2-search__field').type('Recifo{enter}', { delay: 100 })
    cy.get('.button-submit').click()
    cy.get('#flash').contains('Horzono elektita sukcese')
    cy.get('.home').contains('Ameriko/Recifo (UTC -03)')
    cy.get('.home').contains('Ŝanĝi horzonon')

    cy.get('#select-timezone-link').click()
    cy.get('#remove-timezone-link').click()
    cy.get('.home').contains('Vi vidas la eventojn laŭ ilia loka horzono')
    cy.get('.home').contains('Elekti horzonon')
    cy.get('#flash').contains('Horzona informo forviŝita sukcese')
  })
})
