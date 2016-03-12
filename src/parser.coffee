xml2js = require('xml2js')

parser = new xml2js.Parser {
  trim: true
  normalize: true
  emptyTag: null
  explicitArray: false
}

module.exports = parser
