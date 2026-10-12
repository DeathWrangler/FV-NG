package Classes.util
{
   import Engine.Classes.WorldObject;
   
   public class WorldIdUtil
   {
      
      public static const TEMP_ID_START:int = 63000;
      
      public static const TEMP_ID_END:int = 65500;
      
      protected static var s_wrappedTempIds:Boolean = false;
      
      protected static var s_curTempID:int = TEMP_ID_START;
      
      public function WorldIdUtil()
      {
         super();
      }
      
      public static function getNewTempId() : int
      {
         var result:int = 0;
         if(!s_wrappedTempIds)
         {
            result = s_curTempID;
            incrementCurrentTempId();
         }
         return result;
      }
      
      public static function resetTempIdStart() : void
      {
         s_curTempID = TEMP_ID_START;
      }
      
      public static function assignTempIdToWorldObject(worldObject:WorldObject) : void
      {
         var alreadyThere:Boolean = false;
         var objects:Array = null;
         var objIdx:int = 0;
         var objLen:uint = 0;
         var test:WorldObject = null;
         if(worldObject != null)
         {
            alreadyThere = false;
            if(s_wrappedTempIds)
            {
               objects = Global.world.getObjects();
               objIdx = 0;
               objLen = objects.length;
               while(objIdx < objLen)
               {
                  test = objects[objIdx] as WorldObject;
                  if(test != null)
                  {
                     if(test.getId() == s_curTempID)
                     {
                        alreadyThere = true;
                        break;
                     }
                  }
                  objIdx++;
               }
            }
            if(alreadyThere == false)
            {
               worldObject.setId(s_curTempID);
            }
            incrementCurrentTempId();
         }
      }
      
      private static function incrementCurrentTempId() : void
      {
         ++s_curTempID;
         if(s_curTempID > TEMP_ID_END)
         {
            s_curTempID = TEMP_ID_START;
            s_wrappedTempIds = true;
         }
      }
   }
}

