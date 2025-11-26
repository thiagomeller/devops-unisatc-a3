import { test, expect } from '@playwright/test';

test.describe('Strapi E2E Tests', () => {
  // Login antes de cada teste
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:1337/admin');
    await page.fill('input[name="email"]', 'admin@satc.edu.br');
    await page.fill('input[name="password"]', 'welcomeToStrapi123');
    await page.click('button[type="submit"]');
    await expect(page.locator('text=Welcome')).toBeVisible({ timeout: 15000 });
  });

  test('Deve criar uma nova Categoria', async ({ page }) => {
    await page.click('text=Content Manager');
    await page.click('a[href*="api::category.category"]'); // Clica em Categoria no menu
    await page.click('text=Create new entry');
    
    // Preenche o nome da categoria
    await page.fill('input[name="name"]', 'DevOps A3 Test');
    
    // Salva
    await page.click('button:has-text("Save")');
    await expect(page.locator('text=Saved')).toBeVisible();
  });

  test('Deve criar um novo Autor', async ({ page }) => {
    await page.click('text=Content Manager');
    await page.click('a[href*="api::author.author"]'); // Clica em Autor no menu
    await page.click('text=Create new entry');
    
    // Preenche o nome do autor
    await page.fill('input[name="name"]', 'Aluno SATC');
    // Preenche o email (campo deve existir na collection author)
    await page.fill('input[name="email"]', 'aluno@satc.edu.br');
    
    await page.click('button:has-text("Save")');
    await expect(page.locator('text=Saved')).toBeVisible();
  });
});
