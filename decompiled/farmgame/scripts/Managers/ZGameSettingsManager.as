package Managers
{
   import Classes.ZItem.ZItemBase;
   
   public class ZGameSettingsManager
   {
      
      protected var m_idHash:Object = new Object();
      
      protected var m_nameHash:Object = new Object();
      
      public function ZGameSettingsManager()
      {
         super();
      }
      
      protected function addZItem(zItemBase:ZItemBase, name:String, code:String) : void
      {
         this.m_idHash[code] = zItemBase;
         this.m_nameHash[name] = zItemBase;
      }
      
      public function getZItemBaseByCode(code:String) : ZItemBase
      {
         return this.m_idHash[code];
      }
      
      public function getZItemBaseByName(name:String) : ZItemBase
      {
         return this.m_nameHash[name];
      }
   }
}

