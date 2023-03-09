// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
Cypress.Commands.add(
  'login',
  (email = 'admin@eventaservo.org', password = 'administranto') => {
    cy.session('admin', () => {
      cy.visit('https://localhost:3000')
      cy.contains('Ensaluti / Registriĝi').click()
      cy.get('#user_email').type(email)
      cy.get('#user_password').type(password)
      cy.get('.button-submit').click()
      cy.url().should('be.equal', 'https://localhost:3000/')
      cy.contains('Sukcesa ensaluto')
    })
  }
)
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })
