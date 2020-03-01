//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Shafer Hess on 2/17/20.
//  Copyright © 2020 Shafer Hess. All rights reserved.
//

import AlamofireImage
import MessageInputBar
import MBProgressHUD
import Parse
import UIKit

protocol DeleteDelegate: class {
    func deletePost(objectId: String)
}

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DeleteDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    
    let myRefreshController = UIRefreshControl()
    var posts = [PFObject]()
    var numPosts: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.estimatedRowHeight = 475
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshController.addTarget(self, action: #selector(getPosts), for: .valueChanged)
        self.tableView.refreshControl = myRefreshController
        
        getPosts()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add Comment
        let post = posts[indexPath.section]
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["author"] = PFUser.current()!
        comment["post"] = post
        
        post.add(comment, forKey: "comments")
        
        post.saveInBackground { (success, error) in
            if(success) {
                print("Comment Saved")
            } else {
                print("Error: \(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    @objc func getPosts() {
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.order(byDescending: "createdAt")
        query.limit = numPosts
        
        self.posts.removeAll()
        query.findObjectsInBackground { (posts, error) in
            if(posts != nil) {
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshController.endRefreshing()
            }
        }
    }
    
    func getMorePosts() {
        numPosts += 10
        getPosts()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
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
            
            if(!cell.commentLabel.text!.isEmpty) {
                cell.commentAuthorLabel.text = user.username
            } else {
                cell.commentAuthorLabel.text = ""
            }
            
            // Check if User has Profile Picture
            let profilePictureImage = user["profile_picture"] as? PFFileObject

            if let profilePicture = profilePictureImage {
                let profilePictureUrlString = profilePicture.url!
                let profilePictureUrl = URL(string: profilePictureUrlString)!
                
                cell.profilePictureView.af_setImage(withURL: profilePictureUrl)
            } else {
                cell.profilePictureView.image = UIImage(systemName: "person.crop.circle.fill")
            }

            // Check if we can display delete button on post
            if(user.username == PFUser.current()?.username) {
                cell.deleteButton.isHidden = false
            } else {
                cell.deleteButton.isHidden = true
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            let user = comment["author"] as! PFUser
            
            cell.usernameLabel.text = user.username
            cell.commentLabel.text = comment["text"] as? String
            
            let profilePictureImage = user["profile_picture"] as? PFFileObject

            if let profilePicture = profilePictureImage {
                let profilePictureUrlString = profilePicture.url!
                let profilePictureUrl = URL(string: profilePictureUrlString)!
                
                cell.profileImageView.af_setImage(withURL: profilePictureUrl)
            } else {
                cell.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row + 1 == numPosts) {
            getMorePosts()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
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
                            self.getPosts()
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
