package Widgets.Frames
{
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import mx.utils.StringUtil;
   
   public class HalloweenInnovationGhoulInventionPreviewFrame extends FarmSlotContainerFrame
   {
      
      private var INVENTION_TF:String = "invention_tf";
      
      private const MESSAGE_TF:String = "message_tf";
      
      private const ICON0_MC:String = "icon0_mc";
      
      private const ICON1_MC:String = "icon1_mc";
      
      private const ICON2_MC:String = "icon2_mc";
      
      private const ICON3_MC:String = "icon3_mc";
      
      private const ICON4_MC:String = "icon4_mc";
      
      private const TICK1_MC:String = "tick1_mc";
      
      private const TICK2_MC:String = "tick2_mc";
      
      private const TICK3_MC:String = "tick3_mc";
      
      private const TICK4_MC:String = "tick4_mc";
      
      private var REWARD1_TF:String = "reward1_tf";
      
      private const REWARD2_TF:String = "reward2_tf";
      
      private var CLOSE_BT:String = "close_bt";
      
      private const REWARD_ICONS:Array = ["furryfreak","madclaw","supremeshell","darkdoom"];
      
      private var m_ticks:Array = [];
      
      private var m_featureName:String = "";
      
      private var m_part1Mc:FarmIcon;
      
      private var m_part2Mc:FarmIcon;
      
      private var m_part3Mc:FarmIcon;
      
      private var m_part4Mc:FarmIcon;
      
      private var m_icon0Mc:FarmIcon;
      
      private var m_icon1Mc:FarmIcon;
      
      private var m_icon2Mc:FarmIcon;
      
      private var m_icon3Mc:FarmIcon;
      
      private var m_icon4Mc:FarmIcon;
      
      private var m_messageTf:ZwTextField;
      
      private var m_inventionTf:ZwTextField;
      
      private var m_tick1Mc:MovieClip;
      
      private var m_tick2Mc:MovieClip;
      
      private var m_tick3Mc:MovieClip;
      
      private var m_tick4Mc:MovieClip;
      
      private var m_reward1Tf:ZwTextField;
      
      private var m_reward2Tf:ZwTextField;
      
      private var m_closeBt:FarmButton;
      
      private var m_invention:int;
      
      private var m_manager:HalloweenInnovationGhoulManager = null;
      
      public function HalloweenInnovationGhoulInventionPreviewFrame(element:DisplayObject, featureName:String, manager:HalloweenInnovationGhoulManager, invention:int)
      {
         this.m_featureName = featureName;
         this.m_manager = manager;
         super(element);
         if(m_element.hasOwnProperty(this.INVENTION_TF))
         {
            this.m_inventionTf = addWidget(new ZwTextField(m_element[this.INVENTION_TF],"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.MESSAGE_TF))
         {
            this.m_messageTf = addWidget(new ZwTextField(m_element[this.MESSAGE_TF],"See how your decorative invention upgrades with every part!")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.REWARD1_TF))
         {
            this.m_reward1Tf = addWidget(new ZwTextField(m_element[this.REWARD1_TF],"Fully Upgraded")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.REWARD2_TF))
         {
            this.m_reward2Tf = addWidget(new ZwTextField(m_element[this.REWARD2_TF],"Harvestable till 10th Dec 2018")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.ICON0_MC))
         {
            this.m_icon0Mc = addWidget(new FarmIcon(m_element[this.ICON0_MC])) as FarmIcon;
         }
         if(m_element.hasOwnProperty(this.ICON1_MC))
         {
            this.m_icon1Mc = addWidget(new FarmIcon(m_element[this.ICON1_MC])) as FarmIcon;
         }
         if(m_element.hasOwnProperty(this.ICON2_MC))
         {
            this.m_icon2Mc = addWidget(new FarmIcon(m_element[this.ICON2_MC])) as FarmIcon;
         }
         if(m_element.hasOwnProperty(this.ICON3_MC))
         {
            this.m_icon3Mc = addWidget(new FarmIcon(m_element[this.ICON3_MC])) as FarmIcon;
         }
         if(m_element.hasOwnProperty(this.ICON4_MC))
         {
            this.m_icon4Mc = addWidget(new FarmIcon(m_element[this.ICON4_MC])) as FarmIcon;
         }
         if(m_element.hasOwnProperty(this.TICK1_MC))
         {
            this.m_tick1Mc = m_element[this.TICK1_MC] as MovieClip;
            this.m_tick1Mc.visible = false;
            this.m_ticks.push(this.m_tick1Mc);
         }
         if(m_element.hasOwnProperty(this.TICK2_MC))
         {
            this.m_tick2Mc = m_element[this.TICK2_MC] as MovieClip;
            this.m_tick2Mc.visible = false;
            this.m_ticks.push(this.m_tick2Mc);
         }
         if(m_element.hasOwnProperty(this.TICK3_MC))
         {
            this.m_tick3Mc = m_element[this.TICK3_MC] as MovieClip;
            this.m_tick3Mc.visible = false;
            this.m_ticks.push(this.m_tick3Mc);
         }
         if(m_element.hasOwnProperty(this.TICK4_MC))
         {
            this.m_tick4Mc = m_element[this.TICK4_MC] as MovieClip;
            this.m_tick4Mc.visible = false;
            this.m_ticks.push(this.m_tick4Mc);
         }
         this.setBasicFrameData(invention);
      }
      
      private function setBasicFrameData(invention:int) : void
      {
         var icons:Array = [this.m_icon0Mc,this.m_icon1Mc,this.m_icon2Mc,this.m_icon3Mc];
         this.m_inventionTf.text = this.m_manager.getFriendlyNameForReward(invention,this.m_manager.FINAL_PART);
         this.m_icon4Mc.loadIcon(Global.getAssetURL(StringUtil.substitute("assets/decorations/marbless{0}.swf",this.REWARD_ICONS[invention])));
         this.m_icon4Mc.setIconSize(150,150);
         for(var i:int = 0; i <= this.m_manager.FINAL_PART; i++)
         {
            icons[i].loadIcon(this.m_manager.getAssetURL(this.m_manager.ANIMAL_ICON,invention,i + 1));
         }
      }
      
      public function setFrameData(invention:int) : void
      {
         var i:int = 0;
         this.m_invention = invention;
         this.m_icon0Mc.visible = true;
         this.m_icon1Mc.visible = true;
         this.m_icon2Mc.visible = true;
         this.m_icon3Mc.visible = true;
         this.m_icon4Mc.visible = true;
         var inventionData:Object = this.m_manager.getActiveGameData();
         for(i = 0; i < this.m_ticks.length; i++)
         {
            if(invention < inventionData.activeInvention)
            {
               this.m_ticks[i].visible = true;
            }
            else if(invention == inventionData.activeInvention)
            {
               this.m_ticks[i].visible = i < inventionData.activePart;
            }
            else
            {
               this.m_ticks[i].visible = false;
            }
         }
      }
   }
}

