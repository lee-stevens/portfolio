# portfolio

Personal portfolio site for lee-stevens.dev, built with [Astro](https://astro.build) as a static site.

## Structure

- [src/pages/index.astro](src/pages/index.astro) — the whole page: hero, experience, projects, contact. Edit the `experience` and `projects` arrays at the top to update content.
- [src/layouts/BaseLayout.astro](src/layouts/BaseLayout.astro) — shared `<head>` and global styles/theme.

## Commands

| Command           | Action                                          |
| :----------------- | :----------------------------------------------- |
| `npm install`       | Install dependencies                             |
| `npm run dev`        | Start local dev server at `localhost:4321`        |
| `npm run build`      | Build the static site to `./dist/`                |
| `npm run preview`    | Preview the production build locally              |

## Deploying

`npm run build` outputs plain static files to `dist/` — serve that directory with whatever you're already using to self-host lee-stevens.dev (nginx, Caddy, etc.), no server runtime required.
