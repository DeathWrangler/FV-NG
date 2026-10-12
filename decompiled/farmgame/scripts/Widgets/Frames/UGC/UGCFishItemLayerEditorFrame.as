package Widgets.Frames.UGC
{
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemState;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.StatsManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class UGCFishItemLayerEditorFrame extends UGCItemLayerEditorFrame
   {
      
      public function UGCFishItemLayerEditorFrame(element:DisplayObject, ugcItemState:UGCItemState)
      {
         super(element,ugcItemState);
         m_toggleManager.allowDeselectOnClick = false;
      }
      
      override protected function setupData() : void
      {
         var allItems:Array = null;
         var idx:uint = 0;
         var isEAUser:Boolean = false;
         var marketPrereq:String = null;
         var startDate:String = null;
         var items:Array = new Array();
         if(m_layerDefinition != null)
         {
            allItems = m_layerDefinition.items;
            for(idx = 0; idx < allItems.length; idx++)
            {
               if(allItems[idx])
               {
                  isEAUser = Boolean(allItems[idx].checkMarketPrereqs());
                  marketPrereq = allItems[idx].marketPrereqName;
                  if(marketPrereq)
                  {
                     if(isEAUser)
                     {
                        items.push(allItems[idx]);
                     }
                     else
                     {
                        startDate = allItems[idx].limitedStartDate;
                        if(Boolean(startDate) && FarmGameUtil.checkStartDateGate(startDate))
                        {
                           items.push(allItems[idx]);
                        }
                     }
                  }
                  else
                  {
                     items.push(allItems[idx]);
                  }
               }
            }
         }
         m_slotData = items;
      }
      
      override protected function onPageBack(event:Event) : void
      {
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_scroll","","left");
         super.onPageBack(event);
      }
      
      override protected function onPageForward(event:Event) : void
      {
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_scroll","","right");
         super.onPageForward(event);
      }
   }
}

