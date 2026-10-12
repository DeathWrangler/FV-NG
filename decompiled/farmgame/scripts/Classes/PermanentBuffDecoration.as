package Classes
{
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   
   public class PermanentBuffDecoration extends BuffDecoration
   {
      
      public function PermanentBuffDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onPlacedFirstTime() : void
      {
         var buff:Buff = getBuff();
         buff.apply(true);
      }
      
      override protected function showPlacementDialog() : void
      {
      }
      
      override protected function updateToolTipText() : void
      {
         var tooltipKeyNew:String = null;
         var hasTooltipKeyNew:Boolean = false;
         var tooltipKey:String = null;
         var hasTooltipKey:Boolean = false;
         var toolTip:String = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
         if(!Global.worldManager.isVisiting())
         {
            hasTooltipKeyNew = false;
            hasTooltipKey = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_item.hasPropertyInDataSource("tooltipKeyNew"))
               {
                  hasTooltipKeyNew = true;
                  tooltipKeyNew = m_item.getStringFromDataSource("tooltipKeyNew");
               }
               if(m_item.hasPropertyInDataSource("tooltipKey"))
               {
                  hasTooltipKey = true;
                  tooltipKey = m_item.getStringFromDataSource("tooltipKey");
               }
            }
            else
            {
               if(m_item.xml.hasOwnProperty("tooltipKeyNew"))
               {
                  hasTooltipKeyNew = true;
                  tooltipKeyNew = m_item.xml.tooltipKeyNew;
               }
               if(m_item.xml.hasOwnProperty("tooltipKey"))
               {
                  hasTooltipKey = true;
                  tooltipKey = m_item.xml.tooltipKey;
               }
            }
            if(this.isNew)
            {
               if(hasTooltipKeyNew)
               {
                  toolTip += "\n" + ZLocUtils.t("Dialogs",tooltipKeyNew);
               }
               else
               {
                  toolTip += "\n " + ZLocUtils.t("Dialogs","PermanentBuffApplying");
               }
            }
            else if(hasTooltipKey)
            {
               toolTip += "\n" + ZLocUtils.t("Dialogs",tooltipKey);
            }
            else
            {
               toolTip += "\n " + ZLocUtils.t("Dialogs","NeverExpires");
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function isSellable() : Boolean
      {
         return false;
      }
      
      override public function isClearable() : Boolean
      {
         return false;
      }
   }
}

