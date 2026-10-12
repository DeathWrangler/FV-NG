package Widgets.Frames.FeedTrough
{
   import Classes.FeedTroughBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwAbstractSlotContainerFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FeedTrough.FeedTroughSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FeedTroughSlotContainerFrame extends ZwAbstractSlotContainerFrame
   {
      
      private static const SLOT_PREFIX:String = "slot";
      
      private static const SLOT_SUFFIX:String = "_mc";
      
      private var m_building:FeedTroughBuilding;
      
      public function FeedTroughSlotContainerFrame(element:DisplayObject, building:FeedTroughBuilding)
      {
         this.m_building = building;
         super(element);
         addWidget(new ZwTextField((element as MovieClip).bulletinTitle_tf,ZLocUtils.t("Dialogs","RecentlySpotted")));
         addWidget(new ZwTextField((element as MovieClip).bulletinBottom_tf,ZLocUtils.t("Dialogs","BulletinBody")));
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_SUFFIX;
      }
      
      override protected function setupData() : void
      {
         var index:int = 0;
         var animal:Object = null;
         m_slotData = new Array();
         var adoptableAnimals:Array = this.m_building.getAdoptableAnimals();
         if(adoptableAnimals != null)
         {
            for(index = 0; index < adoptableAnimals.length; index++)
            {
               animal = {
                  "code":adoptableAnimals[index],
                  "newItem":false,
                  "foundItem":false
               };
               if(index == 0)
               {
                  animal.newItem = true;
               }
               if(Global.player.hasAdoptedAnimal(adoptableAnimals[index]))
               {
                  animal.foundItem = true;
               }
               m_slotData.push(animal);
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeedTroughSlot(slotElement);
      }
   }
}

