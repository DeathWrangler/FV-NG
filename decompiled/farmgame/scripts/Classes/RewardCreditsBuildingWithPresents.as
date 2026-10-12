package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FeaturePresentsManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class RewardCreditsBuildingWithPresents extends RewardCreditsBuilding
   {
      
      protected var m_showStoragePresentsTabOnLoad:Boolean = false;
      
      public function RewardCreditsBuildingWithPresents(buildingType:String = null, featureName:String = null)
      {
         super(buildingType,featureName);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         super.displayStorageDialog();
         this.m_showStoragePresentsTabOnLoad = false;
         this.hideArrowDisplay();
      }
      
      override protected function checkArrowIndicator() : void
      {
         var itemFlag:String = null;
         var hasLastPresent:Boolean = false;
         var spr:Sprite = null;
         if(!m_showingArrow && !m_usingLoadingGraphic && !UI.isShowingPopup() && !Global.worldManager.isVisiting())
         {
            if(super.canShowPreOffboardArrow())
            {
               m_arrow = super.generatePreOffBoardingArrowIndicator();
               m_nullArrow = false;
            }
            else
            {
               itemFlag = Global.player.getItemFlag(this.m_creditsFeatureName + "_lastPresent");
               hasLastPresent = itemFlag != "" && itemFlag != null;
               if(hasLastPresent)
               {
                  spr = m_displayObject as Sprite;
                  if(m_arrow == null && spr.numChildren > 0)
                  {
                     this.m_hideArrow = false;
                     m_arrow = this.generateArrowIndicator();
                     this.showStoragePresentsTabOnLoad = true;
                     m_nullArrow = false;
                  }
               }
            }
            if(m_arrow != null && m_nullArrow == false)
            {
               m_arrow.visible = true;
               (m_displayObject as Sprite).addChild(m_arrow);
               this.setArrowPosition();
               m_showingArrow = true;
            }
         }
      }
      
      override protected function setArrowPosition() : void
      {
         var arrowOffsets:Array = null;
         var curArrowOffset:Number = NaN;
         var arrowOffset:Object = null;
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(m_arrow) && Boolean(m_displayObject) && m_arrowPositionSet == false)
         {
            arrowOffsets = new Array();
            arrowOffsets = Global.farmGameSettingsManager.getBuildingArrowOffsets(getCreditsFeatureName());
            if(null != arrowOffsets)
            {
               m_arrow.x = ARROW_X_OFFSET;
               m_arrow.y = ARROW_Y_OFFSET;
               for(curArrowOffset = 0; curArrowOffset < arrowOffsets.length; curArrowOffset++)
               {
                  arrowOffset = arrowOffsets[curArrowOffset];
                  if(arrowOffset.name == "xOffset")
                  {
                     m_arrow.x = arrowOffset.value;
                  }
                  if(arrowOffset.name == "yOffset")
                  {
                     m_arrow.y = arrowOffset.value;
                  }
               }
            }
            else
            {
               point = new Point();
               spr = m_displayObject as Sprite;
               m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
               m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
               if(spr.getChildAt(0))
               {
                  point.y = -1 * Math.min(m_arrow.height,DEFAULT_ARROW_SIZE_Y);
                  point.x = (spr.getChildAt(0).width - Math.min(m_arrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
                  if(point.x != m_arrow.x || point.y != m_arrow.y)
                  {
                     m_arrow.y = point.y + m_displayObject.y - m_displayObject.height - this.getTotalCreditsReceived() / 2 - 50;
                     m_arrow.x = point.x - 20;
                  }
               }
            }
            m_arrowPositionSet = true;
         }
      }
      
      protected function generateArrowIndicator() : DisplayObject
      {
         var lastPresentCode:String = Global.player.getItemFlag(m_creditsFeatureName + "_lastPresent");
         var lastPresentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(lastPresentCode);
         var iconPath:String = Global.getAssetURL(this.getPresentIndicatorIconUrl());
         var title:String = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_IndicatorPresentWaitingTitle");
         var text:String = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_IndicatorPresentWaitingText");
         var validOpenDate:String = Global.farmGameSettingsManager.getAttribute(m_creditsFeatureName + "OpenPresentDate");
         var validToOpen:Boolean = FarmGameUtil.synchronizedDateToNumber(validOpenDate) < GlobalEngine.serverTime;
         if(validToOpen)
         {
            title = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_IndicatorOpenNowTitle");
            text = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_IndicatorOpenNowText");
         }
         return new ArrowIndicatorWindow(iconPath,title,text);
      }
      
      public function getPresentIndicatorIconUrl() : String
      {
         return getBuildingImageUrl("presentIndicatorIconUrl");
      }
      
      public function getSendPresentFeedIconUrl() : String
      {
         return getBuildingImageUrl("sendPresentFeedIcon");
      }
      
      override public function hideArrowDisplay() : void
      {
         if(Boolean(m_arrow) && Boolean(m_arrow.visible) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
            Global.player.setItemFlag(this.m_creditsFeatureName + "_lastPresent","",true);
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      public function set showStoragePresentsTabOnLoad(show:Boolean) : void
      {
         this.m_showStoragePresentsTabOnLoad = show;
      }
      
      public function get showStoragePresentsTabOnLoad() : Boolean
      {
         return this.m_showStoragePresentsTabOnLoad;
      }
      
      override protected function getOwnerToolTipText() : String
      {
         var redeemItem:FarmItem = null;
         var tooltip:String = "";
         var count:int = int(this.getCurrentCredits());
         var localizedTotal:String = this.m_creditsFeatureName + "_TooltipTotalGifts_Plural";
         if(count == 1)
         {
            localizedTotal = this.m_creditsFeatureName + "_TooltipTotalGifts_Single";
         }
         tooltip += ZLocUtils.t("Dialogs",localizedTotal,{"quantity":count}) + "\n";
         var nextRedeemReward:Object = this.getNextRedeemReward();
         if(nextRedeemReward.creditsNeeded > 0)
         {
            redeemItem = Global.farmGameSettingsManager.getFarmItemByName(nextRedeemReward.itemName);
            if(redeemItem)
            {
               tooltip += ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_TooltipMoreToEarn",{
                  "quantity":nextRedeemReward.creditsNeeded,
                  "item":ZLocUtils.tk_pk(redeemItem.friendlyName)
               }) + "\n";
            }
         }
         var localizedPresents:String = this.m_creditsFeatureName + "_TooltipPresentsReceived_Plural";
         if(FeaturePresentsManager.getInstance().featurePresents.length == 1)
         {
            localizedPresents = this.m_creditsFeatureName + "_TooltipPresentsReceived_Single";
         }
         return tooltip + ZLocUtils.t("Dialogs",localizedPresents,{"quantity":FeaturePresentsManager.getInstance().featurePresents.length});
      }
   }
}

