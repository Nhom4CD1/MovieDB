//
//  MoviesTableViewController.swift
//  NTA_MoviesDB
//
//  Created by THANH on 5/19/17.
//  Copyright © 2017 HCMUTE. All rights reserved.
//

import UIKit
class MoviesTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
   
    @IBOutlet var spinner: UIActivityIndicatorView! //Bieu tuong doi waitting /loading
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredMovies = [Movie]()
    //lay session mac dinh
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    
    var movies = [Movie]()
    //bien phuc vu cho multiThread
    var queue = OperationQueue()
    var loadingData = false
    var refreshPage = 0
    var p = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovie(page: p)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        //
        self.tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        //Aanr spinner
        spinner.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // trả về số lượng phim
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredMovies.count
        }
        return movies.count
    }
    
    // Đẩy  dữ liệu vào TableCell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Movie_Cell", for: indexPath)
        let movie: Movie
        //nếu chế độ tìm kiếm được bật và Nội dung searchBar không rỗng => Lọc phim
        if searchController.isActive && searchController.searchBar.text != "" {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        cell.imageView?.image = #imageLiteral(resourceName: "default")
        //đưa thread vào hàng đợi
        queue.addOperation { () -> Void in
            if movie.poster != nil {
                if let img = ImagefromUrl.downloadImageWithURL("\(prefixImg)\(movie.poster!)") {
                    OperationQueue.main.addOperation({
                        self.movies[indexPath.row].anhPhim = img
                        cell.imageView?.image = img
                    })
                }
            }
        }
        cell.textLabel?.text = movie.tieudePhim
        cell.detailTextLabel?.text = movie.noidungChinh
        return cell
    }
    //load more
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Nếu chês độ tìm đang tắt
        if !searchController.isActive {
            if !loadingData && indexPath.row == refreshPage - 1 {
                spinner.isHidden = false// Hiện Spinner
                spinner.startAnimating()
                loadingData = true
                loadMovie(page: p)
            }
        }
    }
    
    // Gửi Request lên trang The MovieDB để lấy dữ liệu các bộ phim hiện có về
    func loadMovie(page:Int) {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(API)&language=en-US&page=\(page)")
        
        dataTask = defaultSession.dataTask(with: url! as URL) {
            data, response, error in
            
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                            // Lấy các thông tin cần thiết từ mảng results được trang web trả về
                            if let array: AnyObject = response["results"] {
                                for movieDictonary in array as! [AnyObject] {
                                    if let movieDictonary = movieDictonary as? [String: AnyObject], let title = movieDictonary["title"] as? String {
                                        let movie_id = movieDictonary["id"] as? Int
                                        let poster = movieDictonary["poster_path"] as? String
                                        let overview = movieDictonary["overview"] as? String
                                        let releaseDate = movieDictonary["release_date"] as? String
                                        self.movies.append(Movie(maPhim: movie_id, tieudePhim: title, poster: poster, noidungChinh: overview, ngayKhoiChieu: releaseDate, anhPhim: #imageLiteral(resourceName: "default")))
                                    } else {
                                        print("Không phải là một dictionary")
                                    }
                                }
                                //
                                self.refreshPage += 20
                                self.tableView.reloadData()
                                self.spinner.stopAnimating()
                                self.spinner.isHidden = true
                                self.loadingData = false
                                self.p += 1
                            } else {
                                print("Results key không tìm thấy trong dictionary")
                            }
                        } else {
                            print("JSON Error")
                        }
                    } catch let error as NSError {
                        print("Error parsing results: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadSections(IndexSet(integersIn: 0...0), with: UITableViewRowAnimation.top)
                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
                    }
                    
                }
            }
        }
        
        dataTask?.resume()
    }
    
    // MARK: - Navigation
    // Lấy thông tin để chuyển sang view Movie Detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "xem_chitiet":
                let movieDetailVC = segue.destination as! MovieDetailViewController
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    movieDetailVC.id = idAtIndexPath(indexPath: indexPath as NSIndexPath)
                    movieDetailVC.image = imageAtIndexPath(indexPath: indexPath as NSIndexPath)
                }
                break
                
            default:
                break
            }
        }
    }
    
    // MARK: - Lấy mã phim tại vị trí được chọn
    
    func idAtIndexPath(indexPath: NSIndexPath) -> Int
    {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredMovies[indexPath.row].maPhim!
        } else {
            return movies[indexPath.row].maPhim!
        }
    }
    //Lấy ảnh từ IndexPath
    func imageAtIndexPath(indexPath: NSIndexPath) -> UIImage
    {
        return movies[indexPath.row].anhPhim!
        
    }
    //Lọc phim
    func filterContentForSearchText(searchText: String) {
        filteredMovies = movies.filter { movie in
            return  (movie.tieudePhim?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    // cập nhật kết quả tìm kiếm
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
// Class hỗ trợ tải hình ảnh từ một URL xác định
class ImagefromUrl {
    class func downloadImageWithURL(_ url:String) -> UIImage! {
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
}
