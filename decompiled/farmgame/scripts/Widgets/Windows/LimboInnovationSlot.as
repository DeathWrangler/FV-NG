package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.LimboInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LimboInnovationSlot extends ZwSlotFrame
   {
      
      private var m_goToButton:FarmAnimatedTextButton;
      
      private var m_count_tf:FarmTextField;
      
      private var m_check_mc:ZwWidget;
      
      private var m_complete_mc:ZwWidget;
      
      private var m_tileTitle:FarmTextField;
      
      private var m_tileDesc:FarmTextField;
      
      private var m_parentWindow:LimboInnovationWindow;
      
      private const TILE_MC:String = "title1_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const DESCRP_TF:String = "description1_tf";
      
      private const CHECK_MC:String = "completeIcon_mc";
      
      private const COMPLETE_MC:String = "complete_mc";
      
      private const GOTO_BT:String = "building_bt";
      
      private const ICON_MC:String = "icon_mc";
      
      private var m_buildingId:String;
      
      private var m_buildingName:String;
      
      private var m_maxLevel:int;
      
      private var m_rewardIcon:ResourcePreviewFrame;
      
      private var m_objectPreviewFrame:ResourcePreviewFrame;
      
      private var m_rewardUrl:String;
      
      private var m_featureName:String;
      
      private var BUILD_COMP_TEXT:String = "_building_complete";
      
      private var BUILD_INCOMP_TEXT:String = "_building_incomplete";
      
      private var BONUS_COMP_TEXT:String = "_bonus_building_complete";
      
      private var BONUS_INCOMP_TEXT:String = "_bonu_building_incomplete";
      
      private var m_isBonusSlot:Boolean = false;
      
      private var m_isBuildingCompleted:Boolean = false;
      
      public function LimboInnovationSlot(element:MovieClip, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow as LimboInnovationWindow;
         this.m_featureName = this.m_parentWindow.featureName;
         if(m_element.hasOwnProperty(this.TILE_MC))
         {
            this.m_tileTitle = new FarmTextField(m_element[this.TILE_MC],"");
            addWidget(this.m_tileTitle);
         }
         if(m_element.hasOwnProperty(this.DESCRP_TF))
         {
            this.m_tileDesc = new FarmTextField(m_element[this.DESCRP_TF],"");
            addWidget(this.m_tileDesc);
         }
         if(m_element[this.COUNT_TF])
         {
            this.m_count_tf = new FarmTextField(m_element[this.COUNT_TF],"1/3");
            addWidget(this.m_count_tf);
         }
         if(m_element[this.CHECK_MC])
         {
            this.m_check_mc = addWidget(new ZwWidget(m_element[this.CHECK_MC]),false) as ZwWidget;
         }
         if(m_element[this.COMPLETE_MC])
         {
            this.m_complete_mc = addWidget(new ZwWidget(m_element[this.COMPLETE_MC]),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_rewardIcon = new ResourcePreviewFrame(m_element[this.ICON_MC]));
         }
         if(m_element.hasOwnProperty(this.GOTO_BT))
         {
            this.m_goToButton = new FarmAnimatedTextButton(m_element[this.GOTO_BT],"Go to Building",this.openBuildingUI);
            this.m_goToButton.visible = true;
         }
      }
      
      private function openBuildingUI(e:Event) : void
      {
         this.m_parentWindow.close();
         switch(this.m_buildingId)
         {
            case LimboInnovationManager.ELITEHORSES_BUILDING:
               FeatureCraftingManager.instance.showUI(this.m_buildingName);
               break;
            case LimboInnovationManager.BIGBUILDABLE_BUILDING:
            case LimboInnovationManager.HARVESTBUILDABLE_BUILDING:
               GivingBuildingWindow.openBuildingUI(this.m_buildingName);
         }
         FarmStatsManager.count("limbo_innovation",this.m_buildingName,"go_to_building","click");
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_buildingId = data.id;
         this.m_maxLevel = data.max;
         this.m_buildingName = data.name;
         this.m_rewardUrl = data.url;
         this.refreshSlot();
         this.renderItem();
      }
      
      private function refreshSlot() : void
      {
         var maxLevel:int = 0;
         var currentLevel:int = 0;
         if(this.m_tileTitle)
         {
            this.m_tileTitle.visible = true;
            this.m_tileTitle.text = LimboInnovationManager.getInstance().getRewardFriendlyName(this.m_buildingId);
         }
         if(this.m_buildingId == LimboInnovationManager.BONUS_REWARD_ID)
         {
            this.m_complete_mc.visible = false;
            this.m_isBonusSlot = true;
            if(LimboInnovationManager.getInstance().isBonusRewarded())
            {
               this.m_isBuildingCompleted = true;
               this.m_check_mc.visible = true;
            }
         }
         else
         {
            maxLevel = this.m_maxLevel;
            currentLevel = LimboInnovationManager.getInstance().getCurrentBuildingLevel(this.m_buildingId);
            if(this.m_count_tf)
            {
               this.m_count_tf.text = currentLevel + "/" + maxLevel;
               this.m_count_tf.visible = true;
            }
            this.m_isBuildingCompleted = false;
            if(currentLevel >= maxLevel)
            {
               this.m_check_mc.visible = true;
               this.m_complete_mc.visible = true;
               if(this.m_goToButton)
               {
                  this.m_goToButton.visible = false;
               }
               this.m_isBuildingCompleted = true;
            }
         }
         this.updateBuildingText();
      }
      
      private function updateBuildingText() : void
      {
         var description:String = null;
         if(this.m_tileDesc)
         {
            this.m_tileDesc.visible = true;
            if(this.m_isBonusSlot)
            {
               description = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.BONUS_INCOMP_TEXT);
               if(this.m_isBuildingCompleted)
               {
                  description = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.BONUS_COMP_TEXT);
               }
            }
            else
            {
               description = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.BUILD_INCOMP_TEXT,{"buildingName":this.buildingName});
               if(this.m_isBuildingCompleted)
               {
                  description = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.BUILD_COMP_TEXT,{"buildingName":this.buildingName});
               }
            }
            this.m_tileDesc.text = description;
         }
      }
      
      private function renderItem() : void
      {
         var urlsplit:Array = null;
         var exportedName:String = null;
         if(this.m_rewardUrl)
         {
            if(m_element.hasOwnProperty("icon_mc"))
            {
               this.m_objectPreviewFrame = getWidget(m_element.icon_mc) as ResourcePreviewFrame;
               if(this.m_objectPreviewFrame)
               {
                  removeWidget(this.m_objectPreviewFrame);
               }
               urlsplit = this.m_rewardUrl.substring(this.m_rewardUrl.lastIndexOf("/") + 1).split(".");
               exportedName = urlsplit[0];
               this.m_objectPreviewFrame = new ResourcePreviewFrame(m_element.icon_mc,this.m_rewardUrl,exportedName);
               addWidget(this.m_objectPreviewFrame,true);
            }
         }
      }
      
      private function get buildingName() : String
      {
         return LimboInnovationManager.getInstance().getBuildingFriendlyName(this.m_buildingId);
      }
      
      override public function release() : void
      {
         this.m_objectPreviewFrame = null;
         this.m_rewardUrl = null;
         this.m_buildingId = null;
         this.m_buildingName = null;
         this.m_check_mc = null;
         this.m_complete_mc = null;
         this.m_count_tf = null;
         this.m_goToButton = null;
         this.m_parentWindow = null;
         this.m_rewardIcon = null;
         super.release();
      }
   }
}

