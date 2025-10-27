const fs = require('fs');

// Dosyayı oku
const data = JSON.parse(fs.readFileSync('src/migrationsv3/config/countries-data-v2.json', 'utf8'));

// on üçüncükardeş: SON BATCH - TARIHI KODLAR BULUNDU
// Araştırma sonucu tarihi/eski ISO kodlar bulundu:
// YU/YUG (Yugoslavia), RH/RHO (Rhodesia), CS/CSK (Czechoslovakia)
// Diğerleri için resmi/historical kod yok
// 12. Batch: Son kalan ülkelere (eski kodlar + boş)
const updates = [
  // Tek geçerli modern kod: Kosovo
  { name: 'Kosovo', iso2: 'XK', iso3: 'XKS' },

  // Tarihi kodlar - eski hükümetler için
  { name: 'Rhodesia', iso2: 'RH', iso3: 'RHO' },
  { name: 'Yugoslavia', iso2: 'YU', iso3: 'YUG' },
  { name: 'Czechoslovakia', iso2: 'CS', iso3: 'CSK' },

  // Diğer tarihsel devletler için resmi kod yok: boş kalacak
  // Free City of Danzig, Tristan da Cunha, European Union, Palestine (British Mandate), British India
];

updates.forEach(update => {
  const index = data.findIndex(row => row.name === update.name);
  if (index !== -1) {
    data[index].iso2 = update.iso2;
    data[index].iso3 = update.iso3;
    console.log(`${update.name}: ${update.iso2}, ${update.iso3}`);
  }
});

// Güncellenmiş veriyi yaz
fs.writeFileSync('src/migrationsv3/config/countries-data-v2.json', JSON.stringify(data, null, 2));

console.log('11. batch - 10 ülkenin ISO kodları güncellendi.');

// Sonraki durumu göster
const remainingEmptyCountries = data.filter(row => !row.iso2 && row.name);
console.log(`\nSonraki durüm: ${remainingEmptyCountries.length} boş ülke kaldı`);
if (remainingEmptyCountries.length > 0) {
  const nextBatch = remainingEmptyCountries.slice(0, 10);
  console.log('Sonraki batch (13. batch) ülkeleri:');
  nextBatch.forEach(country => console.log(`- ${country.name}`));
  console.log('\nBu ülkeler için ISO kodlarını ara ve script\'i güncelle.');
}
