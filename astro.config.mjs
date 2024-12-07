import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'UwU guides',
			social: {
				github: 'https://github.com/withastro/starlight',
			},
			sidebar: [
				{
					label: 'How to guides',
					autogenerate: { directory: 'How to guides' },
				},
				{
					label: 'Handy tools',
					autogenerate: { directory: 'Handy tools' },
				},
			],
		}),
	],
});
