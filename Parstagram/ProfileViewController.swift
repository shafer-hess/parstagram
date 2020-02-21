//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Shafer Hess on 2/20/20.
//  Copyright © 2020 Shafer Hess. All rights reserved.
//

import Parse
import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DeleteDelegate {
    // ProfileViewController Outlets
    @IBOutlet weak var tableView: UITableView!
        
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.estimatedRowHeight = 475
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
        
        if(PFUser.current() != nil) {
            self.navigationItem.title = PFUser.current()?.username
        }
        
        getUserPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!

        // Configure Cell with Data
        cell.deleteDelegate = self
        cell.authorLabel.text = user.username
        cell.commentLabel.text = post["caption"] as? String
        cell.postView.af_setImage(withURL: url)
        cell.objectId = post.objectId!

        // Check if we can display delete button on post
        if(user.username == PFUser.current()?.username) {
            cell.deleteButton.isHidden = false
        } else {
            cell.deleteButton.isHidden = true
        }
        
        return cell
    }
    
    func getUserPosts() {
        // Get Current User's ID
        let user = PFUser.current()
        
        // Retrieve
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.whereKey("author", equalTo: user as Any)
        query.order(byDescending: "createdAt")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if(posts != nil) {
                self.posts = posts!
                self.tableView.reloadData()
            } else {
                print("Error: \(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    func deletePost(objectId: String) {
        // Confirm Post Delete Alert UI
        let postDelete = UIAlertController(title: "Are you sure?", message: "Are you sure you want to remove this post? This action cannot be undone.", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        let confirmButton = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            let query = PFQuery(className: "Posts")
            query.whereKey("objectId", equalTo: objectId)

            query.findObjectsInBackground { (posts: [PFObject]?, error) in
                
                for post in posts! {
                    post.deleteInBackground { (success, error) in
                        if(success) {
                            self.getUserPosts()
                            self.tableView.reloadData()
                        } else {
                            print("Error: \(error?.localizedDescription ?? "error")")
                        }
                    }
                }
            }
        }
        
        postDelete.addAction(cancelButton)
        postDelete.addAction(confirmButton)
        
        present(postDelete, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
