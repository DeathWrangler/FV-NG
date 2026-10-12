package Widgets.Slots
{
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HalloweenInnovationGhoulInventionSlot extends HalloweenInnovationGhoulInventionBaseSlot
   {
      
      private const HARVEST_BT:String = "harvest_bt";
      
      private const LOCK_MC:String = "lock_mc";
      
      private var m_featureName:String = "";
      
      private var m_manager:HalloweenInnovationGhoulManager = null;
      
      private var m_lockMc:MovieClip;
      
      private var m_harvestBt:FarmAnimatedTextButton;
      
      private var m_mapToDecoIndex:int;
      
      public function HalloweenInnovationGhoulInventionSlot(element:DisplayObject, featureName:String, manager:HalloweenInnovationGhoulManager, activeInvention:int, inventionIndex:int)
      {
         this.m_featureName = featureName;
         this.m_manager = manager;
         super(element,featureName,manager,activeInvention,inventionIndex);
         if(m_element.hasOwnProperty(this.LOCK_MC))
         {
            this.m_lockMc = m_element[this.LOCK_MC] as MovieClip;
         }
      }
      
      override public function onHitAreaMouseRollOut(event:MouseEvent) : void
      {
         this.m_manager.disbaleInventionPreviewFrame(false);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_mapToDecoIndex = data.Index;
         this.m_lockMc.visible = m_activeInvention < data.Index;
      }
   }
}

