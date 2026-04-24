# Location Quiz 🗺️

A Hugo-based interactive location quiz that sends players around town to find answers to questions.

## How It Works

### For Players

1. **Start the quiz**: Visit the home page and choose to walk the trail **Forward** or **Reverse**
2. **Answer questions**: Read each question and select or type your answer
3. **Find the next location**: When correct, you're shown where to go next in town with:
   - Location name & description
   - Street address
   - GPS coordinates & OS Grid reference
   - Optional What3Words address for easy sharing
4. **Repeat**: Head to that location, find the answer to the next question, and continue
5. **Finish**: Complete all questions to finish the trail!

### Multiple Trails

- If multiple question files are uploaded, buttons for each trail appear on the home screen
- Each trail is independent (Trail 1, Trail 2, Trail 3, etc.)
- Players can switch between trails anytime
- Trails are stored locally in the browser

---

## Architecture

### Files

- **`layouts/_default/quiz.html`** - Quiz flow template (Hugo)
- **`layouts/_default/editor.html`** - Question editor template (Hugo)
- **`docs/`** - Pre-built HTML files served by GitHub Pages
- **`docs/trails/`** - Trail files (`trail-1.json`, `trail-2.json`, etc.) and `trails.json` index
- **`hugo.toml`** - Hugo configuration

### Data Storage

#### Trail 1 (Default)
- Loads from `docs/trails/trail-1.json`

#### Trails 2+ (Custom)
- Stored as `docs/trails/trail-N.json` files and listed in `docs/trails/trails.json`
- Local editor uploads can still override a trail in browser **localStorage**

#### Trail List
- `localStorage.getItem('trail-list')` stores `[1, 2, 3]` as JSON array
- Updated when new trails are uploaded

---

## Question Format

Questions are stored as a JSON array. Each question object has:

```json
{
  "id": 1,
  "type": "multiple",
  "question": "What can you see on the gate here?",
  "options": ["A lion", "An eagle", "A dragon"],
  "correct": 0,
  "reward": {
    "title": "Berkhamsted Castle",
    "description": "Look for the tall tower in the grounds...",
    "address": "Castle Street, Berkhamsted",
    "lat": 51.7652,
    "lng": -0.5621,
    "osGrid": "SP 987 079",
    "w3w": "///filled.count.soap"
  },
  "next": 2
}
```

### Question Types

**Multiple Choice:**
- `type: "multiple"`
- `options` - array of answer choices
- `correct` - index of correct option (0-based)

**Free Text:**
- `type: "text"`
- `correctAnswer` - answer string (case-insensitive)

### Reward Object

After answering correctly, players see the reward:
- `title` - Location name (displayed in large heading)
- `description` - What to look for / context
- `address` - Street address
- `lat`, `lng` - GPS coordinates (used for map)
- `osGrid` - Ordnance Survey grid reference (generated auto-magically from lat/lng)
- `w3w` - What3Words address **(optional)** - links to what3words.com

### Trail Linking

- `next` points to the **next question's ID**
- First question: nothing references its ID
- Last question: `next: null`
- Reverse trail: auto-reverses the chain

---

## Using the Question Editor

### Access

Visit `/editor/` on your site (e.g., `yourdomain.com/location-quiz/editor/`)

### Create Questions

1. **Select Trail** - dropdown at top shows Trail 1, 2, 3...
2. **Create Tab** - Fill in question, answer, and location details
3. **Add Question** - Creates or updates a question
4. **Manage Tab** - List, edit, delete questions

### Edit Existing Questions

1. Switch to **Manage** tab
2. Click **Edit** on any question
3. Form auto-fills with the question data
4. Click **✏️ Update Question** to save changes
5. Or click **Cancel Edit** to discard changes

### Upload New Trail

1. Go to **Manage** tab
2. Click **📄 Upload questions.json**
3. Select a previously downloaded JSON file
4. When prompted, enter the trail number (e.g., `2`)
5. Questions import to that trail instantly
6. New trail appears on the home screen

### Download Questions

1. Go to **Manage** tab
2. Click **📥 Download This Trail**
3. File downloads as `trail-1-questions.json` (or trail-2, etc.)
4. Use this to backup or share questions

---

## Editing Questions on GitHub

To modify Trail 1 questions and push to GitHub:

1. **Download questions**: Use the editor's download button — saves as `trail-1.json`
2. **Copy to repo**: Place the file at `docs/trails/trail-1.json`
3. **Commit & push**:
   ```bash
   git add docs/trails/trail-1.json
   git commit -m "Update Trail 1 questions"
   git push
   ```

### Adding a New Trail

1. Create the trail in the editor, set a name, download as `trail-4.json`
2. Copy to `docs/trails/trail-4.json`
3. Add its filename to `docs/trails/trails.json`:
   ```json
   ["trail-1.json", "trail-2.json", "trail-3.json", "trail-4.json"]
   ```
4. Commit and push — it appears automatically on the home screen!

---

## Coordinate Systems

### Automatic OS Grid Conversion

When you enter lat/lng coordinates in the editor:
- Plugin: **os-transform** (Ordnance Survey's official library)
- Converts to: **OS Grid Reference** (e.g., "SP 987 079")
- Used for: Display only (informational for players)

### What3Words

- **Optional** - not required for any question
- If provided, players see a clickable link to what3words.com
- Handy for giving precise location clues

---

## Multi-Trail System

### How It Works

1. **Trail 1**: Loads from `static/questions.json` (default, on GitHub)
2. **Trails 2+**: Load from `docs/trails/trail-N.json` (on GitHub)
3. **Switching**: Click buttons on home screen or use `?trail=2` URL parameter
4. **Persistence**: Trail data stays in browser until cleared

### Limitations

- Trails 2+ are **not synced to GitHub** (only in browser storage)
- If user clears browser storage, custom trails are lost
- To save custom trails permanently, download as JSON and commit to GitHub

### Adding New Trails

1. Create questions in the editor (Trail 1)
2. Download as JSON
3. Create another set of questions
4. Download as JSON for Trail 2
5. Upload both files to editor with trail numbers (1, 2)
6. Both appear on home screen

---

## Deployment

### Prerequisites

- Hugo (to rebuild templates)
- Git
- GitHub repository

### Build & Deploy

```bash
# Modify templates in layouts/_default/
# The docs/ folder contains pre-built HTML

# Stage changes
git add .
git commit -m "Your changes"
git push

# GitHub Pages serves docs/ folder
# Live at: https://username.github.io/location-quiz/
```

### Local Testing

Since Hugo is blocked, you can:
1. Edit `layouts/_default/*.html` (templates)
2. Manually sync changes to `docs/*.html` (generated)
3. Test in browser by opening `docs/index.html` locally

---

## Troubleshooting

### Questions Not Showing on Home Screen

- Check that the JSON file is valid: use [jsonlint.com](https://jsonlint.com/)
- Ensure the trail file exists in `docs/trails/` and is listed in `docs/trails/trails.json`
- Refresh browser (hard refresh: `Ctrl+Shift+R`)

### OS Grid Shows "Unavailable"

- Make sure `lat` and `lng` values are numbers (not strings)
- Check coordinates are within UK bounds (~50–60° N, -9 to +3° E)
- Refresh page - js libraries may not have loaded yet

### Custom Trails Disappeared

- Clearing browser cache/storage clears Trail 2+
- Always download JSON before clearing data!
- Uploaded trails are temporary unless you commit them to GitHub

### Map Not Loading

- Leaflet.js loads from CDN - check internet connection
- Browser console (F12) should show no errors

---

## Tips & Tricks

- **Test chains**: Use the editor's "Manage" tab to verify `next` links form a complete chain
- **Backup regularly**: Download questions.json periodically
- **Version control**: Commit questions changes to GitHub with descriptive messages
- **Multiple editors**: Different people can edit different trails without conflict
- **Mobile-friendly**: Quiz works on phones! Test on actual devices

---

## Support

Questions or issues? Check the GitHub repository or review the `GUIDE.md` file for GitHub integration steps.

