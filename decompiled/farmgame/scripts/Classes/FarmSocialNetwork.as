package Classes
{
   import Engine.Classes.SocialNetwork;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TPublishPermission;
   
   public class FarmSocialNetwork extends SocialNetwork
   {
      
      public static const SNID_INVALID:Number = -1;
      
      public static const SNID_FACEBOOK:Number = 1;
      
      public static const SNID_ZLIVE:Number = 18;
      
      protected var m_snid:Number = -1;
      
      public var m_isInOAuth:Boolean = false;
      
      protected var m_userIsAdult:Boolean = false;
      
      protected var m_masterId:String = null;
      
      public function FarmSocialNetwork()
      {
         super();
      }
      
      public function getSocialNetworkId() : Number
      {
         return this.m_snid;
      }
      
      public function getLoggedInMasterId() : String
      {
         return null;
      }
      
      public function emailSupported() : Boolean
      {
         return false;
      }
      
      public function userIsAdult() : Boolean
      {
         return this.m_userIsAdult;
      }
      
      public function bookmarkSupported() : Boolean
      {
         return false;
      }
      
      public function oneToOneFeedsSupported() : Boolean
      {
         return false;
      }
      
      public function redirectTop(url:String, variables:Object = null, location:String = "_parent", isRelative:Boolean = true) : void
      {
         this.farmRedirect(url,variables,location,isRelative,true);
      }
      
      override public function onPermissionDialogClosed(userAccepted:Boolean) : void
      {
         if(userAccepted)
         {
            FarmStatsManager.count("extended_permissions","opt-in","fb_diag_accepted");
         }
         else
         {
            FarmStatsManager.count("extended_permissions","opt-in","fb_diag_rejected");
         }
         Global.player.hasPublishPermission = userAccepted;
         if(userAccepted)
         {
            TransactionManager.addTransaction(new TPublishPermission());
         }
         super.onPermissionDialogClosed(userAccepted);
      }
      
      override public function userHasStreamPermissions() : Boolean
      {
         return Global.player.hasPublishPermission;
      }
      
      public function farmRedirect(url:String, variables:Object = null, location:String = "_parent", isRelative:Boolean = true, directToTop:Boolean = false) : void
      {
      }
   }
}

