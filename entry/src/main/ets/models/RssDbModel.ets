export class RssDbObject {
  id: number;
  public  name: string;
  link: string;
  logo: string;
  description: string;
  group:string = '';

  constructor();
  constructor(id: number, name: string, link: string, logo: string, description: string,group?:string);
  constructor(id?: number, name?: string, link?: string, logo?: string, description?: string,group?:string) {
    this.id = id || 0;
    this.name = name || '';
    this.link = link || '';
    this.logo = logo || '';
    this.description = description || '';
    this.group = group
  }
}