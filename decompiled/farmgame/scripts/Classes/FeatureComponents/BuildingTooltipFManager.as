package Classes.FeatureComponents
{
   import Classes.Constants.XMLKeys;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.BuildingTooltipWindow;
   import flash.display.Sprite;
   
   public class BuildingTooltipFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      protected static const DEFAULT_TOOLTIP_HORIZONTAL_OFFSET:Number = 100;
      
      protected static const DEFAULT_TOOLTIP_VERTICAL_OFFSET:Number = 140;
      
      protected static const DEFAULT_TOOLTIP_DELAY:int = 800;
      
      public function BuildingTooltipFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override protected function parseState(stateItem:XML, stateData:BaseDataSource = null) : void
      {
         var stateName:String = null;
         var title:String = null;
         var desc:String = null;
         var buttonText:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(stateData)
            {
               stateName = stateData.getString("name");
               title = stateData.getString("title");
               desc = stateData.getString("desc");
               buttonText = stateData.getString("buttonText");
            }
         }
         else
         {
            stateName = stateItem[XMLKeys.ATTR_NAME];
            title = String(stateItem.title);
            desc = String(stateItem.desc);
            buttonText = String(stateItem.buttonText);
         }
         var splitTitle:Array = title.split(":",2);
         var splitButtonText:Array = buttonText.split(":",2);
         m_states[stateName] = {
            "title":ZLocUtils.t(splitTitle[0],splitTitle[1]),
            "desc":desc,
            "buttonText":ZLocUtils.t(splitButtonText[0],splitButtonText[1])
         };
      }
      
      override protected function drawIndicator(state:String = "default", visible:Boolean = true) : void
      {
         var sprite:Sprite = this.owner.getDisplayObject() as Sprite;
         if(canDisplay())
         {
            if(m_indicator == null && sprite.numChildren > 0)
            {
               this.createIndicator(state);
            }
            if(m_indicator)
            {
               if(this.m_indicator.parent == null)
               {
                  this.setIndicatorPosition();
                  this.attachTooltipToBuilding();
                  (m_indicator as BuildingTooltipWindow).addListeners();
                  Global.stage.addChild(this.m_indicator);
                  m_indicator.visible = true;
                  m_indicatorCurrentlyHidden = false;
               }
            }
         }
      }
      
      public function get featuredItem() : FarmItem
      {
         return null;
      }
      
      override protected function createIndicator(state:String) : void
      {
         var splitText:Array = null;
         var bodyText:String = null;
         var tooltipState:Object = m_states[state];
         var item:FarmItem = this.featuredItem;
         if(tooltipState != null && item != null)
         {
            splitText = tooltipState.desc.split(":",2);
            bodyText = ZLocUtils.t(splitText[0],splitText[1],{"item":ZLocUtils.tk_pk(item.friendlyName)});
            m_indicator = new BuildingTooltipWindow(item.iconUrl,tooltipState.title,bodyText,tooltipState.buttonText,DEFAULT_TOOLTIP_DELAY,owner.onClick);
            this.setIndicatorPosition();
         }
         else
         {
            hide();
         }
      }
      
      override protected function getHorizontalOffset() : Number
      {
         return DEFAULT_TOOLTIP_HORIZONTAL_OFFSET;
      }
      
      override protected function getVerticalOffset() : Number
      {
         return DEFAULT_TOOLTIP_VERTICAL_OFFSET;
      }
      
      override protected function setIndicatorPosition() : void
      {
         var tooltip:BuildingTooltipWindow = m_indicator as BuildingTooltipWindow;
         tooltip.setOffsets(this.getHorizontalOffset(),this.getVerticalOffset());
         tooltip.updatePosition();
      }
      
      protected function attachTooltipToBuilding() : void
      {
         var tooltip:BuildingTooltipWindow = m_indicator as BuildingTooltipWindow;
         tooltip.setBuilding(this.owner);
         tooltip.updatePosition();
      }
      
      override public function onClick() : void
      {
      }
      
      override public function onMouseOver() : void
      {
         if(Boolean(m_indicator) && !m_indicatorCurrentlyHidden)
         {
            (m_indicator as BuildingTooltipWindow).onRollOver();
         }
      }
      
      override public function onMouseOut() : void
      {
         if(Boolean(m_indicator) && !m_indicatorCurrentlyHidden)
         {
            (m_indicator as BuildingTooltipWindow).onRollOut();
         }
      }
   }
}

