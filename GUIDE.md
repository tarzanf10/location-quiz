# Quick Guide: Uploading Questions to GitHub 🚀

## Scenario: You've Created Questions in the Editor

Follow these steps to save them permanently to GitHub.

---

## Step 1: Download Your Questions

1. Open the **Question Editor**: `/editor/` on your site
2. Go to the **Manage** tab
3. Click **📥 Download This Trail**
4. Save the file (e.g., `trail-1-questions.json`)

---

## Step 2: Prepare Your Computer

### If You Don't Have Git Installed

1. Download [Git for Windows](https://git-scm.com)
2. Run the installer (accept defaults)
3. Restart your computer

### If You Don't Have a Code Editor

Use **Visual Studio Code** (free):
1. Download from [code.visualstudio.com](https://code.visualstudio.com)
2. Install it

---

## Step 3: Clone the Repository

1. Open **PowerShell** (Windows) or **Terminal** (Mac/Linux)
2. Navigate to where you want the folder:
   ```bash
   cd Documents
   ```
3. Clone the repository:
   ```bash
   git clone https://github.com/YOUR-ORG/YOUR-REPO.git
   cd YOUR-REPO
   ```

---

## Step 4: Update the Questions File

### Option A: Copy & Paste (Easiest)

1. Open the downloaded `trail-1.json` in a text editor
2. Copy all the contents
3. In VS Code, open `docs/trails/trail-1.json` in the cloned folder
4. Delete all contents and paste your questions
5. Save the file

### Option B: Command Line (Advanced)

```bash
# Copy the downloaded file directly into the trails folder
cp "path/to/downloaded/trail-1.json" docs/trails/trail-1.json
```

> The file is named to match its trail number. When you download from
> the editor, it saves as `trail-1.json`, `trail-2.json`, etc. automatically.

---

## Optional: Convert CSV to Trail JSON (PowerShell)

If your questions are in CSV format, you can convert them automatically.

### 1) Save your CSV in this format

```csv
id,type,question,correctAnswer,title,description,address,lat,lng,osGrid,w3w
1,text,Example question one,Answer 1,Location A,Clue for the next stop,"123 High Street, Berkhamsted, HP4 1AA",51.760000,-0.560000,SP 99000 07800,///example.words.here
2,text,Example question two,Answer 2,Location B,Look for the blue plaque,"125 High Street, Berkhamsted, HP4 1AB",51.761000,-0.561000,SP 99100 07900,///other.words.here
```

### 2) Run the converter script

```powershell
./convert-trail-csv.ps1 -InputCsv "Trail_2.csv" -OutputJson "docs/trails/trail-6.json" -TrailName "My Trail" -TrailDescription "Imported from CSV" -Register
```

### 3) Useful options

- `-Register` adds the new filename to `docs/trails/trails.json`
- `-Overwrite` allows replacing an existing output file
- If you omit `-OutputJson`, the script auto-picks the next `trail-N.json`

### 4) If PowerShell blocks script execution

Some machines enforce script restrictions. In that case, run this in the same folder:

```powershell
$code = Get-Content "./convert-trail-csv.ps1" -Raw
$scriptBlock = [ScriptBlock]::Create($code)
& $scriptBlock -InputCsv "Trail_2.csv" -OutputJson "docs/trails/trail-6.json" -TrailName "My Trail" -TrailDescription "Imported from CSV" -Register
```

---

## Printables from the Website

Printable sheets are available on a dedicated page:

- `/printables/`

### How to print

1. Open `/printables/` on your site
2. Choose your trail
3. Click either **Questions only** or **With answers**
4. When it opens, press `Ctrl+P` (Windows) or `Cmd+P` (Mac) to print

### Direct URL format (optional)

If needed, you can still open printables directly by URL:

- `.../printables/trail-4-questions.md`
- `.../printables/trail-4-with-answers.md`
- `.../printables/trail-5-questions.md`
- `.../printables/trail-5-with-answers.md`

---

## Step 5: Check the File is Valid

1. Open the updated `docs/questions.json` in VS Code
2. Look for **red squiggly lines** = errors
3. Common issues:
   - Missing commas between objects
   - Unclosed quote marks
   - Extra commas before closing brackets `]`
4. If unsure, paste the content into [jsonlint.com](https://jsonlint.com/) to validate

---

## Step 6: Commit to Git

1. In PowerShell/Terminal, make sure you're in the `location-quiz` folder:
   ```bash
   cd location-quiz
   ```
2. Check what's changed:
   ```bash
   git status
   ```
   You should see `docs/trails/trail-1.json` listed
   
3. Stage the file:
   ```bash
   git add docs/trails/trail-1.json
   ```
4. Commit with a message:
   ```bash
   git commit -m "Update Trail 1 questions: Added castle entrance quiz"
   ```
   *(Replace the message with what you changed)*

5. Push to GitHub:
   ```bash
   git push
   ```

---

## Step 7: Verify on GitHub

1. Go to your GitHub repo (e.g. `https://github.com/YOUR-ORG/YOUR-REPO`)
2. Click **Code** tab
3. Open `docs/trails/trail-1.json` - you should see your new questions!
4. Check **GitHub Pages** is enabled:
   - Go to **Settings** → **Pages**
   - Source: "Deploy from a branch"
   - Branch: `main` / `docs` folder ✓

---

## Step 8: Test Live Site

Wait 30 seconds, then visit your live site:
- Main site: your GitHub Pages URL (e.g. `https://YOUR-ORG.github.io/YOUR-REPO/`)
- Questions should be updated!

---

## Troubleshooting

### Error: "Could not open repo"
- Make sure you cloned into a **local folder** (not Documents online)
- Try: `cd ~/location-quiz` then `git status`

### Error: "No changes staged for commit"
- Make sure you edited the correct files:
   - `docs/trails/trail-1.json`
   - (If adding a new trail) `docs/trails/trails.json`

### Site not updating after push?
- GitHub Pages can take up to 1 minute
- Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
- Check if "GitHub Pages" is enabled (Settings → Pages)

### Questions file has errors?
1. Open in VS Code
2. Copy contents to [jsonlint.com](https://jsonlint.com/)
3. Fix errors shown
4. Copy back to the file
5. Save & commit again

---

## Uploading Additional Trails

If you want Trail 2, Trail 3, etc:

### For Storage in Browser (Temporary)

1. In the editor, click **📄 Upload questions.json**
2. Select your file
3. When asked, enter trail number: `2`
4. Trail 2 appears on home screen!

> **Note**: Browser storage is temporary. Clear browser data = trails disappear!

### For Storage on GitHub (Permanent)

1. Download your trail from the editor — it saves as `trail-2.json`
2. Copy it to `docs/trails/trail-2.json`
3. Add its filename to `docs/trails/trails.json`:
   ```json
   ["trail-1.json", "trail-2.json"]
   ```
4. Commit and push:
   ```bash
   git add docs/trails/trail-2.json docs/trails/trails.json
   git commit -m "Add Trail 2"
   git push
   ```
5. Trail 2 appears automatically on the home screen!

---

## Common Questions

**Q: Will my questions go live immediately?**
A: They appear in GitHub instantly, but the live site may take up to 1 minute to refresh.

**Q: Can I edit questions directly in GitHub?**
A: Yes! Open `docs/questions.json`, click ✏️ to edit, then commit. But use the editor for easier updates.

**Q: What if I made a mistake?**
A: Undo: `git revert HEAD` or push again with corrected questions.

**Q: Can multiple people edit at once?**
A: Yes! But take turns with big changes. Small edits can be merged automatically.

**Q: Do I need to update both `static/` and `docs/`?**
A: No — only files inside `docs/trails/` matter. That folder is served by GitHub Pages.

---

## Still Stuck?

1. Check the main [README.md](README.md) for detailed architecture info
2. Review your JSON file with [jsonlint.com](https://jsonlint.com/)
3. Open an issue in the GitHub repo or ask for help!

---

**You've got this! 🎉**

