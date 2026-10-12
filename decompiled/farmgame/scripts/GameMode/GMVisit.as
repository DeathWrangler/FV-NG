package GameMode
{
   import Classes.Constants.Experiments;
   import Classes.FarmGameObject;
   import Classes.ImageLoader;
   import Classes.ItemInstance;
   import Classes.MapResource;
   import Classes.NeighborVisitAvatar;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Managers.ExperimentManager;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class GMVisit extends GMDefault
   {
      
      protected var m_tag:DisplayObject;
      
      protected var m_tagUrl:String;
      
      protected var m_hostId:String;
      
      protected var m_inSignPostExperiment:Boolean;
      
      protected var m_inNeighborClickTestExperiment:Boolean;
      
      protected var m_inNeighborVisitPurchaseExperiment:Boolean;
      
      public function GMVisit(hostId:String)
      {
         var tagLoader:ImageLoader = null;
         super();
         this.m_hostId = hostId;
         var expMan:ExperimentManager = Global.experimentManager;
         this.m_inNeighborVisitPurchaseExperiment = expMan.getExperimentVariant(Experiments.EXPERIMENT_NEIGHBOR_VISIT_PURCHASE) > 0;
         this.m_inSignPostExperiment = false;
         this.m_inNeighborClickTestExperiment = 0 >= Experiments.VARIANT_NEIGHBOR_CLICK_TEST_ENABLED;
         if(this.itemPurchasingEnabled)
         {
            this.m_tagUrl = this.getTagUrl();
            if(this.m_tagUrl)
            {
               tagLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_tagUrl),true);
               tagLoader.getContent(this.tagImageLoaded);
            }
         }
      }
      
      protected function getTagUrl() : String
      {
         return Global.farmGameSettingsManager.getString("neighborLEItemTagUrl");
      }
      
      protected function get itemPurchasingEnabled() : Boolean
      {
         return this.m_inNeighborVisitPurchaseExperiment;
      }
      
      private function tagImageLoaded(tag:DisplayObject) : void
      {
         if(tag)
         {
            this.m_tag = tag;
            GlobalEngine.viewport.hudBase.addChild(this.m_tag);
            this.m_tag.visible = false;
         }
      }
      
      override protected function getSelectableTypes() : int
      {
         if(this.m_inSignPostExperiment && Global.worldManager.isVisiting() || this.m_inNeighborClickTestExperiment)
         {
            return Constants.WORLDOBJECT_ALL;
         }
         return Constants.WORLDOBJECT_ALL_EXCEPT_AVATAR;
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var itemInst:ItemInstance = null;
         if(this.itemPurchasingEnabled)
         {
            if(object != m_highlightedObject)
            {
               this.deselectObject();
               m_highlightedObject = object;
               if(object)
               {
                  object.setHighlighted(true);
                  object.onMouseOver(event);
                  itemInst = object as ItemInstance;
                  if(itemInst)
                  {
                     if(this.canPurchaseItem(itemInst))
                     {
                        this.conditionallyShowLETag(itemInst);
                        this.selectPurchasableItem(itemInst);
                     }
                     else
                     {
                        this.selectNonPurchasableItem(itemInst);
                     }
                  }
               }
               this.updateCursor();
            }
         }
         else
         {
            super.selectObject(object,event);
         }
      }
      
      protected function conditionallyShowLETag(itemInst:ItemInstance) : void
      {
         var farmItem:FarmItem = null;
         if(Boolean(itemInst) && Boolean(this.m_tag) && !itemInst.tag)
         {
            farmItem = itemInst.getItem();
            if(this.canPurchaseFarmItem(farmItem) && farmItem.isLimitedItem())
            {
               Global.world.positionTagOverItem(this.m_tag,itemInst);
               this.m_tag.visible = true;
            }
         }
      }
      
      protected function selectPurchasableItem(itemInst:ItemInstance, event:MouseEvent = null) : void
      {
         var itemResource:MapResource = itemInst as MapResource;
         if(itemResource)
         {
            itemResource.setOverrideToolTip(ZLocUtils.t("FarmGame","Neighbor_MouseOverText_Buy_Cash",{
               "item":ZLocUtils.tk_pk(itemInst.getItemFriendlyName()),
               "quantity":itemInst.getItem().cash
            }));
         }
      }
      
      protected function selectNonPurchasableItem(itemInst:ItemInstance, event:MouseEvent = null) : void
      {
         super.selectObject(itemInst,event);
      }
      
      override protected function deselectObject() : void
      {
         super.deselectObject();
         if(this.m_tag)
         {
            this.m_tag.visible = false;
         }
      }
      
      override protected function canBeClicked(event:MouseEvent) : Boolean
      {
         if(this.m_inNeighborClickTestExperiment)
         {
            return m_highlightedObject is FarmGameObject || m_highlightedObject is NeighborVisitAvatar;
         }
         return m_highlightedObject is FarmGameObject;
      }
      
      protected function canPurchaseHighlightedObject() : Boolean
      {
         var result:Boolean = false;
         if(m_highlightedObject)
         {
            result = this.canPurchaseItem(m_highlightedObject as ItemInstance);
         }
         return result;
      }
      
      protected function canPurchaseItem(itemInst:ItemInstance) : Boolean
      {
         return Boolean(itemInst) && this.canPurchaseFarmItem(itemInst.getItem());
      }
      
      protected function canPurchaseFarmItem(farmItem:FarmItem) : Boolean
      {
         return Boolean(farmItem) && farmItem.buyableFromNeighbor;
      }
      
      override protected function updateCursor() : void
      {
         if(m_highlightedObject is FarmGameObject && (m_highlightedObject as FarmGameObject).canUpdateCursorOnVisit())
         {
            super.updateCursor();
         }
         else if(null != m_currentCursor)
         {
            if(m_cursorId > 0)
            {
               UI.removeCursor(m_cursorId);
               m_cursorId = 0;
            }
            m_currentCursor = null;
         }
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         if(this.m_inNeighborClickTestExperiment)
         {
            return object is FarmGameObject || object is NeighborVisitAvatar;
         }
         return object is FarmGameObject;
      }
      
      override public function disableMode() : void
      {
         if(Boolean(this.m_tag) && Boolean(this.m_tag.parent))
         {
            this.m_tag.parent.removeChild(this.m_tag);
         }
         super.disableMode();
      }
   }
}

