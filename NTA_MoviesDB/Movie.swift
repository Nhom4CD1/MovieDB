//
//  Movie.swift
//  NTA_MoviesDB
//
//  Created by THANH on 5/19/17.
//  Copyright © 2017 HCMUTE. All rights reserved.
//

import UIKit

class Movie{
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
        var maPhim: Int?
        var tieudePhim: String?
        var poster: String?
        var noidungChinh: String?
        var ngayKhoiChieu: String?
        var anhPhim: UIImage?
        
        //khoi tao
        init(maPhim: Int?, tieudePhim: String?, poster: String?, noidungChinh: String?, ngayKhoiChieu: String?, anhPhim: UIImage?) {
            self.maPhim = maPhim
            self.tieudePhim = tieudePhim
            self.poster = poster
            self.noidungChinh = noidungChinh
            self.ngayKhoiChieu = ngayKhoiChieu
            self.anhPhim = anhPhim
        }
}

