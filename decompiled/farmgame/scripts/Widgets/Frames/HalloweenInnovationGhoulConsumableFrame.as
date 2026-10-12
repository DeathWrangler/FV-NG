package Widgets.Frames
{
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HalloweenInnovationGhoulConsumableFrame extends FarmSlotContainerFrame
   {
      
      private const COUNT_TF:String = "count_tf";
      
      private const UNLOCK_TF:String = "unlock_tf";
      
      private const HIT_AREA_MC:String = "hit_area_mc";
      
      private const CONSUMABLE_ICON_MC:String = "icon_mc";
      
      private const CONSUMABLE_TF:String = "consumable_tf";
      
      private const UNLOCK_BT:String = "unlock_bt";
      
      private var m_featureName:String = "";
      
      private var m_manager:HalloweenInnovationGhoulManager = null;
      
      private var m_unlockBt:FarmAnimatedTextButton;
      
      private var m_consumableTf:ZwTextField;
      
      private var m_fireboltCountTf:ZwTextField;
      
      public function HalloweenInnovationGhoulConsumableFrame(element:DisplayObject, featureName:String, manager:HalloweenInnovationGhoulManager, origin:String)
      {
         var hitAreaMC:MovieClip = null;
         var consumableIconMC:FarmIcon = null;
         this.m_featureName = featureName;
         this.m_manager = manager;
         super(element);
         if(m_element.hasOwnProperty(this.COUNT_TF))
         {
            addWidget(this.m_fireboltCountTf = new ZwTextField(m_element[this.COUNT_TF],"x" + this.m_manager.getOrderboardProgress()));
         }
         if(m_element.hasOwnProperty(this.CONSUMABLE_TF))
         {
            this.m_consumableTf = new ZwTextField(m_element[this.CONSUMABLE_TF],"Firebolts") as ZwTextField;
            addWidget(this.m_consumableTf);
            this.m_consumableTf.visible = true;
         }
         if(m_element.hasOwnProperty(this.UNLOCK_TF))
         {
            if(origin == "mainWindow")
            {
               addWidget(new ZwTextField(m_element[this.UNLOCK_TF],"Unlock tiles to get more Firebolts"));
            }
            else
            {
               addWidget(new ZwTextField(m_element[this.UNLOCK_TF],"Use 1 Firebolt to uncover 1 glass cell"));
            }
         }
         if(m_element.hasOwnProperty(this.HIT_AREA_MC))
         {
            hitAreaMC = m_element[this.HIT_AREA_MC] as MovieClip;
            hitAreaMC.visible = true;
         }
         if(m_element.hasOwnProperty(this.CONSUMABLE_ICON_MC))
         {
            consumableIconMC = addWidget(new FarmIcon(m_element[this.CONSUMABLE_ICON_MC])) as FarmIcon;
            consumableIconMC.loadIcon(this.m_manager.getFireboltIcon());
            consumableIconMC.visible = true;
         }
         if(m_element.hasOwnProperty(this.UNLOCK_BT))
         {
            addWidget(this.m_unlockBt = new FarmAnimatedTextButton(m_element[this.UNLOCK_BT],"View Tiles",this.onUnlockBtnClick));
            this.m_unlockBt.visible = true;
         }
      }
      
      private function onUnlockBtnClick(event:Event) : void
      {
         this.m_manager.showBoostUI();
      }
      
      override public function refresh() : void
      {
         this.m_fireboltCountTf.text = "x" + this.m_manager.getOrderboardProgress();
      }
   }
}

