package com.facebook.data.users
{
   import com.facebook.data.FacebookData;
   import com.facebook.data.FacebookLocation;
   
   [Bindable]
   public class FacebookUser extends FacebookData
   {
      
      public var status:StatusData;
      
      public var has_added_app:Boolean;
      
      public var pic_with_logo:String;
      
      public var pic_big_with_logo:String;
      
      public var notes_count:int;
      
      public var pic_small:String;
      
      public var political:String;
      
      public var music:String;
      
      public var religion:String;
      
      public var significant_other_id:int;
      
      public var email_hashes:Array;
      
      public var movies:String;
      
      public var uid:String;
      
      public var hometown_location:FacebookLocation;
      
      public var wall_count:int;
      
      public var hs2_name:String;
      
      public var proxied_email:String;
      
      public var sex:String;
      
      public var hs_info:String;
      
      public var work_history:Array;
      
      public var meeting_sex:Array;
      
      public var pic_square:String;
      
      public var quotes:String;
      
      public var hs1_id:int;
      
      public var locale:String;
      
      public var birthday:String;
      
      public var tv:String;
      
      public var affiliations:Array;
      
      public var interests:String;
      
      public var pic:String;
      
      public var name:String = "";
      
      public var grad_year:String;
      
      public var about_me:String;
      
      public var last_name:String = "";
      
      public var pic_small_with_logo:String;
      
      public var is_app_user:Boolean;
      
      public var hs1_name:String;
      
      public var books:String;
      
      public var first_name:String = "";
      
      public var current_location:FacebookLocation;
      
      public var meeting_for:Array;
      
      public var birthdayDate:Date;
      
      public var networkAffiliations:Array;
      
      public var pic_big:String;
      
      public var relationship_status:String;
      
      public var hs2_id:int;
      
      public var profile_url:String;
      
      public var profile_update_time:Date;
      
      public var activities:String;
      
      public var pic_square_with_logo:String;
      
      public var timezone:int;
      
      public var isLoggedInUser:Boolean;
      
      public var education_history:Array;
      
      public function FacebookUser()
      {
         super();
      }
   }
}

