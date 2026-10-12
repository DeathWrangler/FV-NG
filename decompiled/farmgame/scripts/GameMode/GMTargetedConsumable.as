package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.MapResource;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TUseTargetedConsumable;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GMTargetedConsumable extends GMDefault
   {
      
      private var m_consumable:String;
      
      protected var m_targetObject:MapResource;
      
      protected var m_cursorLoader:Loader;
      
      public function GMTargetedConsumable(consumable:String, isGift:Boolean = true)
      {
         super(isGift);
         this.m_consumable = consumable;
         m_isGift = isGift;
         this.setupCusorLoader();
      }
      
      public function get consumable() : String
      {
         return this.m_consumable;
      }
      
      public function setupCusorLoader() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_consumable);
         if(item)
         {
            this.m_cursorLoader = LoadingManager.load(item.getImageByName("icon"),this.onCursorLoaded,LoadingManager.PRIORITY_HIGH);
         }
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var resource:MapResource = null;
         var result:Boolean = false;
         if(object is MapResource)
         {
            resource = object as MapResource;
            result = resource.canUseConsumable(this.m_consumable);
         }
         return result;
      }
      
      override protected function updateCursor() : void
      {
         if(Boolean(m_cursorImage) && m_cursorId <= 0)
         {
            m_cursorId = UI.setCursor(m_cursorImage,true,shouldScaleCursor());
         }
      }
      
      protected function onCursorLoaded(event:Event) : void
      {
         m_cursorImage = this.m_cursorLoader.content;
         m_cursorId = UI.setCursor(this.m_cursorLoader.content,true,shouldScaleCursor());
      }
      
      override protected function getSelectableTypes() : int
      {
         return WorldObjectTypes.ANIMAL;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var avatar:FarmAvatar = Global.selectedAvatar;
         if(this.canUseConsumable() && !m_dragging)
         {
            if(Boolean(avatar) && Boolean(this.m_targetObject) && Boolean(this.m_consumable))
            {
               TransactionManager.addTransaction(new TUseTargetedConsumable(this.m_consumable,this.m_targetObject.getId(),m_isGift,"",false,m_isGift),true);
               Global.world.removeGameMode(this);
               Global.world.setDefaultGameMode();
            }
         }
         else if(Boolean(m_dragging == false) && Boolean(this.m_targetObject) && this.m_targetObject.getId() == 0)
         {
            this.m_targetObject.showObjectBusy();
         }
      }
      
      private function canUseConsumable() : Boolean
      {
         var result:Boolean = false;
         if(m_highlightedObject)
         {
            if(m_highlightedObject is MapResource)
            {
               this.m_targetObject = m_highlightedObject as MapResource;
               result = this.m_targetObject.canUseConsumable(this.m_consumable);
            }
         }
         return result;
      }
   }
}

