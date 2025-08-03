
class LocationService {
  // Liste des pays
  static const List<String> countries = [
    "Afghanistan", "Afrique du Sud", "Albanie", "Algérie", "Allemagne", "Andorre", "Angola", "Arabie Saoudite", "Argentine", "Arménie",
    "Australie", "Autriche", "Azerbaïdjan", "Bahamas", "Bahreïn", "Bangladesh", "Barbade", "Belgique", "Bénin", "Bhoutan",
    "Biélorussie", "Birmanie", "Bolivie", "Bosnie-Herzégovine", "Botswana", "Brésil", "Brunei", "Bulgarie", "Burkina Faso", "Burundi",
    "Cambodge", "Cameroun", "Canada", "Cap-Vert", "Chili", "Chine", "Chypre", "Colombie", "Comores", "Congo",
    "Corée du Nord", "Corée du Sud", "Costa Rica", "Côte d'Ivoire", "Croatie", "Cuba", "Danemark", "Djibouti", "Égypte", "Émirats arabes unis",
    "Équateur", "Espagne", "Estonie", "États-Unis", "Éthiopie", "Fidji", "Finlande", "France", "Gabon", "Gambie",
    "Géorgie", "Ghana", "Grèce", "Guatemala", "Guinée", "Guinée-Bissau", "Guinée équatoriale", "Guyana", "Haïti", "Honduras",
    "Hongrie", "Inde", "Indonésie", "Irak", "Iran", "Irlande", "Islande", "Israël", "Italie", "Jamaïque",
    "Japon", "Jordanie", "Kazakhstan", "Kenya", "Kirghizistan", "Koweït", "Laos", "Lesotho", "Lettonie", "Liban",
    "Libéria", "Libye", "Lituanie", "Luxembourg", "Macédoine", "Madagascar", "Malaisie", "Malawi", "Mali", "Malte",
    "Maroc", "Maurice", "Mauritanie", "Mexique", "Moldavie", "Monaco", "Mongolie", "Monténégro", "Mozambique", "Namibie",
    "Népal", "Nicaragua", "Niger", "Nigeria", "Norvège", "Nouvelle-Zélande", "Oman", "Ouganda", "Ouzbékistan", "Pakistan",
    "Panama", "Papouasie-Nouvelle-Guinée", "Paraguay", "Pays-Bas", "Pérou", "Philippines", "Pologne", "Portugal", "Qatar", "République centrafricaine",
    "République démocratique du Congo", "République dominicaine", "République tchèque", "Roumanie", "Royaume-Uni", "Russie", "Rwanda", "Sénégal", "Serbie", "Seychelles",
    "Sierra Leone", "Singapour", "Slovaquie", "Slovénie", "Somalie", "Soudan", "Sri Lanka", "Suède", "Suisse", "Suriname",
    "Swaziland", "Syrie", "Tadjikistan", "Tanzanie", "Tchad", "Thaïlande", "Togo", "Tunisie", "Turkménistan", "Turquie",
    "Ukraine", "Uruguay", "Venezuela", "Viêt Nam", "Yémen", "Zambie", "Zimbabwe"
  ];

  // Filtrer les pays selon la recherche
  static List<String> filterCountries(String query) {
    if (query.isEmpty) return countries;
    return countries
        .where((country) => country.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
} 