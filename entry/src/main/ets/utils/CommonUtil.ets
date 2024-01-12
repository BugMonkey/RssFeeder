export class CommonUtil {
  static getUuid(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      const r = Math.random() * 16 | 0
      const v = c === 'x' ? r : (r & 0x3 | 0x8)
      return v.toString(16)
    })
  }

  static groupBy<T>(arr: T[], grouper: (item: T) => string): { [key: string]: T[] } {
    const groups: { [key: string]: T[] } = {};

    for (const item of arr) {
      const key = grouper(item);
      if (groups[key]) {
        groups[key].push(item);
      } else {
        groups[key] = [item];
      }
    }

    return groups;
  }

  static  removeXmlTags(text: string): string {
    const regex = /<[^>]+>/g;
    const spaceRegex = /&nbsp;/g;
    return text.replace(regex, '').replace(spaceRegex,'').replace('\n','');
  }

}