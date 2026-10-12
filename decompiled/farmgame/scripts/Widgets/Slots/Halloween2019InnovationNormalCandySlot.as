package Widgets.Slots
{
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Halloween2019InnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class Halloween2019InnovationNormalCandySlot extends ZwSlotFrame
   {
      
      private static const CANDY_NAME_TF:String = "candy_main_name_tf";
      
      private static const CANDY_COUNT_TF:String = "candy_main_count_tf";
      
      private static const CANDY_IMAGE_MC:String = "candy_main_icon_mc";
      
      private var m_featureName:String;
      
      private var m_owner:Halloween2019InnovationMainWindow;
      
      private var m_candyCountTf:ZwTextField;
      
      private var m_candyNameTf:ZwTextField;
      
      private var m_candyIcon:FarmIcon;
      
      private var m_animationMinusMc:MovieClip;
      
      private var m_animationMinusDooberMc:MovieClip;
      
      private var m_animationMinusTf:ZwTextField;
      
      private var m_slotnumber:int = -1;
      
      private var m_toolTipText:String = "";
      
      public function Halloween2019InnovationNormalCandySlot(featureName:String, element:DisplayObject, window:Halloween2019InnovationMainWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(CANDY_NAME_TF))
         {
            addWidget(this.m_candyNameTf = new ZwTextField(m_element[CANDY_NAME_TF],""));
            this.m_candyNameTf.visible = true;
         }
         if(m_element.hasOwnProperty(CANDY_COUNT_TF))
         {
            addWidget(this.m_candyCountTf = new ZwTextField(m_element[CANDY_COUNT_TF],""));
            this.m_candyCountTf.visible = true;
         }
         if(m_element.hasOwnProperty(CANDY_IMAGE_MC))
         {
            addWidget(this.m_candyIcon = new FarmIcon(m_element[CANDY_IMAGE_MC]));
            this.m_candyIcon.visible = true;
         }
         if(m_element.hasOwnProperty("candy_minus_doober_mc"))
         {
            this.m_animationMinusMc = m_element["candy_minus_doober_mc"] as MovieClip;
            this.m_animationMinusMc.visible = false;
            this.m_animationMinusDooberMc = this.m_animationMinusMc["dooberIcon_minus_mc"] as MovieClip;
            this.m_animationMinusDooberMc.visible = true;
            if(this.m_animationMinusDooberMc.hasOwnProperty("candy_minus_counter_tf"))
            {
               addWidget(this.m_animationMinusTf = new ZwTextField(this.m_animationMinusDooberMc["candy_minus_counter_tf"],"-1"));
               this.m_animationMinusTf.visible = true;
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         this.m_toolTipText = "";
         super.populate(data);
         if(data)
         {
            if(data.hasOwnProperty("questOrderSlotNumber"))
            {
               this.m_slotnumber = data.questOrderSlotNumber;
            }
            if(data.hasOwnProperty("candyCount"))
            {
               this.m_candyCountTf.text = "x" + data.candyCount;
               this.m_candyCountTf.visible = true;
            }
            if(data.hasOwnProperty("candyIcon"))
            {
               this.m_candyIcon.loadIcon(data.candyIcon);
               this.m_candyIcon.setIconSize(50,50);
               this.m_candyIcon.visible = true;
            }
            if(data.hasOwnProperty("candyName"))
            {
               this.m_candyNameTf.text = data["candyName"];
               this.m_candyNameTf.visible = true;
            }
            this.manager.slotCandy[data["candyName"]] = new Array(this.m_animationMinusMc,this.m_animationMinusTf);
         }
      }
      
      private function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance(this.m_featureName);
      }
      
      public function runMinusDoober() : void
      {
         this.m_animationMinusMc.visible = true;
         this.m_animationMinusMc.play();
         this.m_animationMinusTf.visible = true;
      }
   }
}

