project('seven-guis', 'vala', 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk4'),
]

counter_sources = [
    'main.vala'
]

executable (
    '7-guis',
    counter_sources,
    dependencies: dependencies,
    install: true
)
