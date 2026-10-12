package Widgets.Frames
{
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FrontierInnovationForageSlot;
   import Widgets.Windows.FrontierInnovationWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationForageFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_buyBt:FarmAnimatedTextButton;
      
      private var m_closeBt:FarmButton;
      
      private var m_loaderMc:MovieClip;
      
      private const BUY_BT:String = "buy_bt";
      
      private const BODY_TF:String = "body_tf";
      
      private const CLOSE_BT:String = "close_bt";
      
      private const LOADER_MC:String = "loader_mc";
      
      private const AREAS:int = 3;
      
      private var m_window:FrontierInnovationWindow;
      
      private var manager:FrontierInnovationManager;
      
      public function FrontierInnovationForageFrame(element:DisplayObject, featureName:String, window:FrontierInnovationWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         this.m_frameName = element.name;
         this.m_frameName = m_element.name;
         if(m_element.hasOwnProperty(this.BODY_TF))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_element[this.BODY_TF],"FORAGING AREAS")) as ZwTextField;
            this.m_bodyTf.visible = true;
         }
         if(m_element.hasOwnProperty(this.CLOSE_BT))
         {
            this.m_closeBt = addWidget(new FarmButton(m_element.close_bt,this.onCloseButton)) as FarmButton;
            this.m_closeBt.visible = true;
         }
         if(m_element.hasOwnProperty(this.LOADER_MC))
         {
            this.m_loaderMc = m_element[this.LOADER_MC] as MovieClip;
            this.m_loaderMc.visible = false;
         }
      }
      
      public function onCloseButton(event:Event) : void
      {
         this.m_window.disableForageWindow();
      }
      
      public function resetLoadingMc() : void
      {
         if(this.m_loaderMc)
         {
            this.m_loaderMc.visible = false;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationForageSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "area";
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var areas:Array = this.manager.getAreaName();
         var areaImages:Array = this.manager.getAreaImage();
         var pickaxeRequired:Array = this.manager.getAreaPickaxes();
         var timeRequired:Array = this.manager.getForageTime();
         var areaData:Array = this.manager.getForageData() as Array;
         var skipFC:Array = this.manager.getFCForForage();
         for(var i:int = 0; i < this.AREAS; i++)
         {
            m_slotData.push({
               "area":areas[i],
               "areaImage":areaImages[i],
               "pickaxeRequired":pickaxeRequired[i],
               "timeRequired":timeRequired[i],
               "TS":areaData[i][1],
               "FC":skipFC[i],
               "status":areaData[i][2]
            });
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      public function disabledCloseBT() : void
      {
         this.m_closeBt.enabled = false;
      }
      
      public function enabledCloseBT() : void
      {
         this.m_closeBt.enabled = true;
      }
   }
}

