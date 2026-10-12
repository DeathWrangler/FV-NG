package Widgets.Windows.MOTD
{
   import Classes.feed.GenericRewardFeed;
   import Classes.util.MovieClipUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import flash.events.MouseEvent;
   
   public class XTIPremarketingWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      private var m_itemName:String;
      
      private var m_bundleName:String;
      
      protected var m_FireMc:ZwWidget;
      
      protected var m_WaterMc:ZwWidget;
      
      protected var m_EarthMc:ZwWidget;
      
      protected var m_AirMc:ZwWidget;
      
      private var m_closeBt:FarmButton;
      
      private var m_shareBt:FarmAnimatedTextButton;
      
      public function XTIPremarketingWidgetMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["selectFire_mc"])
            {
               this.m_FireMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["selectFire_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["selectWater_mc"])
            {
               this.m_WaterMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["selectWater_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["selectEarth_mc"])
            {
               this.m_EarthMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["selectEarth_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["selectAir_mc"])
            {
               this.m_AirMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["selectAir_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select0_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select0_bt"],"Fire",this.onStone0ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select1_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select1_bt"],"Water",this.onStone1ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select2_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select2_bt"],"Earth",this.onStone2ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select3_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select3_bt"],"Air",this.onStone3ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc["close_bt"])
            {
               this.m_closeBt = addWidget(new FarmButton(m_window.mainWindow.animation_mc["close_bt"],onClose)) as FarmButton;
            }
            if(m_window.mainWindow.animation_mc["share_bt"])
            {
               addWidget(this.m_shareBt = new FarmAnimatedTextButton(m_window.mainWindow.animation_mc["share_bt"],"Share",this.onShareClick),false);
            }
            if(m_animationMc)
            {
               m_animationMc.element.stop();
            }
         }
      }
      
      protected function onStone0ButtonClick(event:MouseEvent) : void
      {
         this.m_FireMc.visible = true;
         this.m_bundleName = "XTIPremarketing_Brag0";
         this.m_itemName = "firestone1";
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.m_shareBt.visible = true;
      }
      
      protected function onStone1ButtonClick(event:MouseEvent) : void
      {
         this.m_WaterMc.visible = true;
         this.m_bundleName = "XTIPremarketing_Brag1";
         this.m_itemName = "waterstone1";
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.m_shareBt.visible = true;
      }
      
      protected function onStone2ButtonClick(event:MouseEvent) : void
      {
         this.m_itemName = "earthstone1";
         this.m_bundleName = "XTIPremarketing_Brag2";
         this.m_EarthMc.visible = true;
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.m_shareBt.visible = true;
      }
      
      protected function onStone3ButtonClick(event:MouseEvent) : void
      {
         this.m_itemName = "airstone1";
         this.m_bundleName = "XTIPremarketing_Brag3";
         this.m_AirMc.visible = true;
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.m_shareBt.visible = true;
      }
      
      protected function onShareClick(event:MouseEvent) : void
      {
         var _item:String = this.m_itemName;
         if(_item)
         {
            new GenericRewardFeed(_item,this.m_bundleName).shareFeed();
         }
         close();
      }
   }
}

