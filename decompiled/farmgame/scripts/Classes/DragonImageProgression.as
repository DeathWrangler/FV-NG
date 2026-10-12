package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Engine.Constants;
   import Events.FarmGameWorldEvent;
   
   public class DragonImageProgression extends AbstractMapResourceImageProgression implements IMapResourceImageProgression
   {
      
      public static const STATE_SMALL:String = "small";
      
      public static const STATE_ADULT:String = "adult";
      
      public static const STATE_WINGS:String = "wings";
      
      public static const STATE_FIRE:String = "fire";
      
      private var m_deferredLoadInProgress:Boolean;
      
      public function DragonImageProgression(resource:MapResource)
      {
         super(resource);
      }
      
      public function getCurrentImageName() : String
      {
         var imageName:String = null;
         var harvestableItem:HarvestableItem = null;
         var mastery:Mastery = null;
         var levelProgress:int = 0;
         var item:FarmItem = m_resource.getItem();
         if(item != null)
         {
            switch(m_resource.getDirection())
            {
               case Constants.DIRECTION_SE:
               case Constants.DIRECTION_SW:
                  imageName = "frt_";
                  break;
               case Constants.DIRECTION_NE:
               case Constants.DIRECTION_NW:
               default:
                  imageName = "bk_";
            }
            harvestableItem = item as HarvestableItem;
            if(harvestableItem != null)
            {
               mastery = harvestableItem.mastery;
               levelProgress = mastery.currentLevel;
               switch(levelProgress)
               {
                  case 0:
                     imageName += STATE_ADULT;
                     break;
                  case 1:
                     imageName += STATE_WINGS;
                     break;
                  case 2:
                     imageName += STATE_FIRE;
                     break;
                  default:
                     imageName += STATE_SMALL;
                     if(!Global.player.postInitFinished)
                     {
                        Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.reloadImage,false,0,true);
                        this.m_deferredLoadInProgress = true;
                     }
               }
            }
            else
            {
               imageName += STATE_SMALL;
            }
         }
         return imageName;
      }
      
      override public function cleanUp() : void
      {
         if(this.m_deferredLoadInProgress)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.reloadImage);
         }
         super.cleanUp();
      }
      
      private function reloadImage(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.reloadImage);
         this.m_deferredLoadInProgress = false;
         m_resource.reloadImage();
      }
   }
}

