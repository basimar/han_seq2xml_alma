# Name: korrektur_006_xml.sed
# Kommandozeile: sed -f korrektur_006_xml.sed dsv05_neu.xml > dsv05_neu_korr.xml

# grep '<marc:controlfield tag="006">' dsv05_neu.xml | sort | uniq | grep -v '.\{73\}'
# liefert die Fälle für die folgenden Ersetzungen in der XML-Datei:

s/<marc:controlfield tag="006">a           |1| |<\/marc:controlfield>/<marc:controlfield tag="006">a           |1| | <\/marc:controlfield>/g
s/<marc:controlfield tag="006">a      6    ||| |<\/marc:controlfield>/<marc:controlfield tag="006">a      6    ||| | <\/marc:controlfield>/g
s/<marc:controlfield tag="006">a           ||| i<\/marc:controlfield>/<marc:controlfield tag="006">a           ||| i <\/marc:controlfield>/g
s/<marc:controlfield tag="006">a      m    ||| |<\/marc:controlfield>/<marc:controlfield tag="006">a      m    ||| | <\/marc:controlfield>/g
s/<marc:controlfield tag="006">c||a<\/marc:controlfield>/<marc:controlfield tag="006">c||a              <\/marc:controlfield>/g
s/<marc:controlfield tag="006">c||c<\/marc:controlfield>/<marc:controlfield tag="006">c||c              <\/marc:controlfield>/g
s/<marc:controlfield tag="006">c||e<\/marc:controlfield>/<marc:controlfield tag="006">c||e              <\/marc:controlfield>/g
s/<marc:controlfield tag="006">c||u<\/marc:controlfield>/<marc:controlfield tag="006">c||u              <\/marc:controlfield>/g
s/<marc:controlfield tag="006">c||z<\/marc:controlfield>/<marc:controlfield tag="006">c||z              <\/marc:controlfield>/g

# Ergebnisprüfung:
# grep '<marc:controlfield tag="006">' dsv05_neu_korr.xml | sort | uniq | grep '.\{73\}'
# bzw.
# grep '<marc:controlfield tag="006">' dsv05_neu_korr.xml | sort | uniq | grep '.\{73\}' | wc -l
# == grep '<marc:controlfield tag="006">' dsv05_neu_korr.xml | sort | uniq | wc -l
# == 16
# sowie
# grep '<marc:controlfield tag="006">' dsv05_neu_korr.xml | sort | uniq | grep -v '.\{73\}' | wc -l
# == 0


