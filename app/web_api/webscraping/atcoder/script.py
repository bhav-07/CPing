from bs4 import BeautifulSoup
from scrapingant_client import ScrapingAntClient
from datetime import datetime, timezone

def datetime_parser(dt):
    year = int(dt[0:4])
    date = int(dt[8:10])
    month = int(dt[5:7])
    hr = int(dt[16:18])
    min = int(dt[19:21])
    dt = datetime(year, month, date, hr, min, tzinfo=timezone.utc)
    return dt.strftime('%Y-%m-%d %H:%M:%Sz')

def parse_row(row):
    tds = row.find_all('td')
    name = tds[1].a.get_text()
    start = datetime_parser(tds[0].get_text())
    length = tds[2].get_text()
    contest = {
        'name': name,
        'start': start,
        'length': length,
        'venue': 'atcoder',
    }
    return contest

# driver code for scraping
def main():
    # page url
    URL = "https://atcoder.jp/contests/"
    # scrapingant client
    client = ScrapingAntClient(token='08195006585c4385956bd98ca77a3f07')
    # sending req
    res = client.general_request(URL)
    # souping
    page = res.content
    soup = BeautifulSoup(page, 'lxml')
    # print(soup)
    # scraping
    contests = {}
    # present contests
    active_contests = []
    for row in soup.select('div#contest-table-action table tbody tr'):    
        active_contests.append(parse_row(row))
    contests['active-contests'] = active_contests
    # future contests
    future_contests = []
    for row in soup.select('div#contest-table-upcoming table tbody tr'):
        future_contests.append(parse_row(row))
    contests['future-contests'] = future_contests
    # print(contests)
    return contests

if __name__ == '__main__':
    main()