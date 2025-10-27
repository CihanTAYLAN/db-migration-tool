const fs = require('fs');
const path = require('path');

const results = [];
new Promise((resolve, reject) => {
  fs.createReadStream(path.join(__dirname, 'src/migrationsv3/config/countries-list.txt'))
    .on('data', (data) => {
      // txt dosyasını satır satır oku (buffer to text)

      const lines = data.toString().trim().split('\n');

      results.push(...lines);

    })
    .on('end', () => {
      console.log('Read Completed');
      resolve(results);
    });
}).then((results) => {
  console.log(results);
  // results dizisini countries-data-v2.json dosyasına yaz
  // {
  //   "name": "Australia",
  //   "iso2": "AU",
  //   "iso3": "AUS"
  // }, şeklinde yazılacak
  const countriesData = results.map((countryName) => {
    return {
      name: countryName,
      iso2: '',
      iso3: '',
    };
  });

  // duplicate check
  const iso2Set = new Set();
  const duplicates = [];
  countriesData.forEach((country) => {
    if (iso2Set.has(country.name)) {
      duplicates.push(country.name);
    } else {
      iso2Set.add(country.name);
    }
  });
  if (duplicates.length > 0) {
    console.log('Duplicate country names found:', duplicates);
  } else {
    console.log('No duplicate country names found.');
  }

  fs.writeFileSync(path.join(__dirname, 'src/migrationsv3/config/countries-data-v2.json'), JSON.stringify(countriesData, null, 2));


  console.log('Countries data written to countries-data-v2.json');
}).catch((error) => {
  console.error('Error reading countries list:', error);
});
