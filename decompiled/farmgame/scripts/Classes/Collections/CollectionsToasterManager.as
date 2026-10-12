package Classes.Collections
{
   import Managers.CollectionsManager;
   import Widgets.Windows.Collections.CollectionsTimerToasterWindow;
   import Widgets.Windows.Collections.CollectionsToasterWindow;
   import Widgets.Windows.Collections.LightningCollectionsToasterWindow;
   import Widgets.Windows.ToasterWindow;
   
   public class CollectionsToasterManager
   {
      
      public function CollectionsToasterManager()
      {
         super();
      }
      
      public static function createToasterPopup(collectableCode:String, shareLink:String = "") : CollectionsToasterWindow
      {
         var newCollection:Collection = CollectionsManager.getInstance().getCollectionByCollectibleCode(collectableCode);
         var toasterPopup:CollectionsToasterWindow = null;
         if(newCollection)
         {
            if(newCollection.type == Collection.TYPE_LIGHTNING)
            {
               toasterPopup = new LightningCollectionsToasterWindow(collectableCode,shareLink);
            }
            else if(newCollection.type != Collection.TYPE_SLOTMACHINE)
            {
               toasterPopup = new CollectionsToasterWindow(collectableCode,shareLink);
            }
         }
         return toasterPopup;
      }
      
      public static function createCountdownPopup(collectionCode:String, endTimeSeconds:Number) : ToasterWindow
      {
         var newCollection:Collection = CollectionsManager.getInstance().getCollection(collectionCode);
         var toasterPopup:ToasterWindow = null;
         if(newCollection)
         {
            if(newCollection.type == Collection.TYPE_LIGHTNING)
            {
               toasterPopup = new CollectionsTimerToasterWindow(endTimeSeconds,newCollection.friendlyName);
            }
         }
         return toasterPopup;
      }
   }
}

