gnome = import('gnome')

gresource = gnome.compile_resources(
	'gresource',
	'data/gresource.xml',
	source_dir: 'data'
)

flight_booker_sources = [
	'Application.vala',
]


flight_booker_exe = executable(
	'flight-booker',
	gresource,
	flight_booker_sources,
	dependencies: dependencies
)
