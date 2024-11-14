import { test, expect } from "@playwright/test";

test.describe("AlertDialog", () => {
  test("has all required elements and functions correctly", async ({
    page,
  }) => {
    await page.goto("http://localhost:4567/component/alert_dialog");

    // Check if the trigger button exists and has correct text
    const triggerButton = page.locator(
      '[data-action="click->ruby-ui--alert-dialog#open"] button',
    );
    await expect(triggerButton).toBeVisible();
    await expect(triggerButton).toHaveText("Show dialog");

    // Ensure the dialog is initially hidden
    const dialog = page.locator('div[role="alertdialog"]');
    await expect(dialog).toBeHidden();

    // Click the trigger to open the dialog
    await triggerButton.click();

    // Ensure the dialog is now visible
    await expect(dialog).toBeVisible();

    // Check dialog content
    await expect(dialog.locator("h2")).toBeVisible();
    await expect(dialog.locator("h2")).toHaveText("Are you absolutely sure?");

    // Check description text
    const description = dialog.locator("p.text-muted-foreground");
    await expect(description).toBeVisible();
    await expect(description).toHaveText(
      "This action cannot be undone. This will permanently delete your account and remove your data from our servers.",
    );

    // Check dialog buttons
    const cancelButton = dialog.locator(
      'button[data-action="click->ruby-ui--alert-dialog#dismiss"]',
    );
    const continueButton = dialog.locator('button:text("Continue")');

    await expect(cancelButton).toBeVisible();
    await expect(cancelButton).toHaveText("Cancel");
    await expect(continueButton).toBeVisible();
    await expect(continueButton).toHaveText("Continue");

    // Check backdrop exists - Using data-state attribute instead of class
    const backdrop = page.locator(
      'div[data-state="open"][data-aria-hidden="true"]',
    );
    await expect(backdrop).toBeVisible();

    // Test dismiss functionality
    await cancelButton.click();
    await expect(dialog).toBeHidden();

    // Test reopening
    await triggerButton.click();
    await expect(dialog).toBeVisible();

    // Finally dismiss again
    await cancelButton.click();
    await expect(dialog).toBeHidden();
  });

  test("dialog maintains correct state after multiple opens/closes", async ({
    page,
  }) => {
    await page.goto("http://localhost:4567/component/alert_dialog");

    const triggerButton = page.locator(
      '[data-action="click->ruby-ui--alert-dialog#open"] button',
    );
    const dialog = page.locator('div[role="alertdialog"]');

    // Test multiple open/close cycles
    for (let i = 0; i < 3; i++) {
      await expect(dialog).toBeHidden();
      await triggerButton.click();
      await expect(dialog).toBeVisible();
      await page
        .locator('button[data-action="click->ruby-ui--alert-dialog#dismiss"]')
        .click();
      await expect(dialog).toBeHidden();
    }
  });

  test("dialog buttons have correct attributes and styling", async ({
    page,
  }) => {
    await page.goto("http://localhost:4567/component/alert_dialog");

    await page
      .locator('[data-action="click->ruby-ui--alert-dialog#open"] button')
      .click();

    const cancelButton = page.locator(
      'button[data-action="click->ruby-ui--alert-dialog#dismiss"]',
    );
    const continueButton = page.locator('button:text("Continue")');

    // Check button attributes
    await expect(cancelButton).toHaveAttribute("type", "button");
    await expect(continueButton).toHaveAttribute("type", "button");

    // Check basic styling classes
    await expect(cancelButton).toHaveAttribute(
      "class",
      expect.stringContaining("bg-background"),
    );
    await expect(continueButton).toHaveAttribute(
      "class",
      expect.stringContaining("bg-primary"),
    );
  });
});
