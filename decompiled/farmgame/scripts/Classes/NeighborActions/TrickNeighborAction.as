package Classes.NeighborActions
{
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.NeighborActions.TTrickNeighbor;
   
   public class TrickNeighborAction extends BaseNeighborAction
   {
      
      public static const validOverlays:Array = ["batOverlay","fogOverlay","ghost"];
      
      public function TrickNeighborAction(object:WorldObject)
      {
         var resource:MapResource = null;
         var overlayName:String = null;
         var webbedBuilding:StorageBuilding = null;
         if(Global.worldManager.isVisiting())
         {
            resource = object as MapResource;
            overlayName = TrickNeighborAction.getOverlay(resource);
            if(resource.isValidOverlayTarget(overlayName))
            {
               webbedBuilding = resource as StorageBuilding;
               if(webbedBuilding)
               {
                  webbedBuilding.applyOverlay(overlayName,webbedBuilding.storageLevel - 1);
                  this.trackStats(resource.getClassName());
               }
            }
            else if(resource.isAltGraphicAvailable(overlayName))
            {
               resource.setAltGraphic(overlayName,0,false);
               this.trackStats(resource.getClassName());
            }
         }
         super(object);
      }
      
      public static function getOverlay(mapObject:MapResource) : String
      {
         var overlayName:String = "";
         for(var i:int = 0; i < validOverlays.length; i++)
         {
            if(mapObject.isAltGraphicAvailable(validOverlays[i]) || mapObject.isValidOverlayTarget(validOverlays[i]))
            {
               overlayName = validOverlays[i];
               break;
            }
         }
         return overlayName;
      }
      
      public static function hasOverlay(mapObject:MapResource) : Boolean
      {
         var result:Boolean = false;
         for(var i:int = 0; i < validOverlays.length; i++)
         {
            if(mapObject.getAlternativeGraphic() == validOverlays[i])
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_TRICK_NEIGHBOR;
      }
      
      override public function getLimitType() : String
      {
         return NeighborActionConstants.LIMIT_TYPE_TRICK_NEIGHBOR_ACTION;
      }
      
      override public function execute() : void
      {
         var object:WorldObject = this.m_object;
         if(object)
         {
            TransactionManager.addTransaction(new TTrickNeighbor(object));
         }
      }
      
      protected function trackStats(itemClass:String) : void
      {
         FarmStatsManager.count("Halloween","Trick",itemClass);
      }
   }
}

