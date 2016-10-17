import sys
import json

def process_acronyms(data):
	acronym_string = ''

	for acronym_data in data:
		acronym = acronym_data['acronym']
		options_string = '{}{}'.format('plural={},'.format(acronym['plural']) if 'plural' in acronym else '', 'shortplural={}'.format(acronym['short-plural']) if 'short-plural' in acronym else '')

		acronym_string = acronym_string + '\\newacronym[{}]{{{}}}{{{}}}{{{}}}\n'.format(options_string, acronym_data['label'], acronym['standard'], acronym_data['full'])

	return acronym_string

print(process_acronyms(json.loads(sys.stdin.read())))
