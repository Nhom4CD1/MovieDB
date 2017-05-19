//
//  MovieDetailViewController.swift
//  NTA_MoviesDB
//
//  Created by THANH on 5/19/17.
//  Copyright © 2017 HCMUTE. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    // Khai báo biến, là các nhãn chứa thông tin film
    @IBOutlet var imgAnhPoster: UIImageView!
    @IBOutlet var lblTieuDe: UILabel!
    @IBOutlet var lblNgayKhoiChieu: UILabel!
    @IBOutlet var lblDanhGia: UILabel!
    @IBOutlet var lblChiPhiSX: UILabel!
    @IBOutlet var lblDoanhThu: UILabel!
    @IBOutlet var lblTongQuanPhim: UILabel!
    
    var id: Int?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMovieDetail()
        title = "CHI TIẾT PHIM"
        imgAnhPoster.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Hàm lấy thông tin chi tiết phim từ trang The MovieDB
    func getMovieDetail() {
        if let movieId = id {
            let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(API)&language=en-US")
            var detail = [String:Any]()
            let request = NSMutableURLRequest(url: url! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
            request.httpMethod = "GET"
            _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (Data, URLResponse, Error) in
                if (Error != nil) {
                    print(Error!)
                } else {
                    do {
                        detail = try JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as! [String:Any]
                        DispatchQueue.main.async {
                            self.lblTieuDe.text = detail["title"]! as? String
                            if let ngay = detail["release_day"] {
                                self.lblNgayKhoiChieu.text = "Ngày Khởi chiếu: \(ngay)"
                            }
                            if let danhgia = detail["vote_average"] {
                                self.lblDanhGia.text = "Đánh giá: ⭐️ \(danhgia)"
                            }
                            if let chiphisx = detail["budget"] {
                                self.lblChiPhiSX.text = "Chi Phí SX: \(chiphisx)$"
                            }
                            if let doanhthu = detail["revenue"] {
                                self.lblDoanhThu.text = "Doanh thu: \(doanhthu)$"
                            }
                            if let tongquanphim = detail["overview"] {
                                self.lblTongQuanPhim.text = "Nội dung chính: \(tongquanphim)"
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }).resume()
        }
    }
}

