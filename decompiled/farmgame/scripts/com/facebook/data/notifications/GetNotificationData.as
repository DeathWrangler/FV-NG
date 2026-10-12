package com.facebook.data.notifications
{
   import com.facebook.data.FacebookData;
   
   [Bindable]
   public class GetNotificationData extends FacebookData
   {
      
      public var notificationCollection:NotificationCollection;
      
      public var event_invites:Array;
      
      public var friendsRequests:Array;
      
      public var group_invites:Array;
      
      public function GetNotificationData()
      {
         super();
      }
   }
}

