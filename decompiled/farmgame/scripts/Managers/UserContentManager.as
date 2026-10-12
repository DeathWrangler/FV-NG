package Managers
{
   import Classes.FarmGameObject;
   import Classes.ItemInstance;
   import Classes.UGC.UGCFeedImage;
   import Classes.UGC.UGCImage;
   import Engine.Managers.TransactionManager;
   import Transactions.TCreateImage;
   import flash.display.BitmapData;
   
   public class UserContentManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:UserContentManager = null;
      
      public static const FEATURE_ANIMAL_BREEDING:String = "animal_breeding";
      
      public static const FEATURE_AVATAR_APPEARANCE:String = "avatar_appearance";
      
      public static const FEATURE_TRADING_POST:String = "trading_post";
      
      public static const FEATURE_SOCIAL_RAFFLE:String = "social_raffle";
      
      public static const FEATURE_UGC_EDITOR:String = "ugc_editor";
      
      public function UserContentManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use UserContentManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : UserContentManager
      {
         if(m_instance == null)
         {
            m_instance = new UserContentManager();
         }
         return m_instance;
      }
      
      public function createFeedImage(contentImage:UGCFeedImage, callback:Function) : void
      {
         TransactionManager.addTransaction(new TCreateImage(contentImage.featureName,contentImage.createEncoded(),"feed_post",callback));
      }
      
      public function getBitmapData(farmObject:FarmGameObject, featureName:String, preferredWidth:Number = 200, preferredHeight:Number = 200) : BitmapData
      {
         var ugcImage:UGCImage = new UGCImage(farmObject,featureName,preferredWidth,preferredHeight);
         if(farmObject is ItemInstance)
         {
            ugcImage.applyConfigTransforms((farmObject as ItemInstance).getItem().ugcTransforms);
         }
         return ugcImage.getBitmapData();
      }
   }
}

