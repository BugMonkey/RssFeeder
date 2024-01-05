export class RssDbModel {
  id: number
  name: string
  link: string
  logo: string
  description: string
  isChecked = false
  constructor(id: number, name: string, link: string, logo: string, description: string) {
    this.id = id
    this.name = name
    this.link = link
    this.logo = logo
    this.description = description
    this.isChecked = false
  }
}