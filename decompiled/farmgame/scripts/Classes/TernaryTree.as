package Classes
{
   public class TernaryTree
   {
      
      private var m_root:TTNode = null;
      
      public var m_matchedStrings:Array = [];
      
      public function TernaryTree()
      {
         super();
      }
      
      private static function add(str:String, pos:int, node:TTNode, result:String) : TTNode
      {
         if(node == null)
         {
            node = new TTNode(str.charCodeAt(pos));
         }
         var cmp:int = str.charCodeAt(pos) - node.m_char;
         if(cmp < 0)
         {
            node.m_left = add(str,pos,node.m_left,result);
         }
         else if(cmp > 0)
         {
            node.m_right = add(str,pos,node.m_right,result);
         }
         else if(pos + 1 == str.length)
         {
            if(node.m_wordEnd == null)
            {
               node.m_wordEnd = [];
            }
            node.m_wordEnd.push(result);
         }
         else
         {
            node.m_center = add(str,pos + 1,node.m_center,result);
         }
         return node;
      }
      
      public function getMatchedStrings() : Array
      {
         return this.m_matchedStrings;
      }
      
      public function addNewString(str:String, result:String) : void
      {
         var nextSpacePos:int = 0;
         str = str.toUpperCase();
         while(str != null && str != "")
         {
            this.m_root = add(str,0,this.m_root,result);
            nextSpacePos = str.indexOf(" ");
            if(nextSpacePos >= 0 && nextSpacePos < str.length - 1)
            {
               str = str.slice(nextSpacePos + 1,str.length);
            }
            else
            {
               str = null;
            }
         }
      }
      
      public function buildPhraseMatchStrings(str:String) : void
      {
         var cmp:int = 0;
         var pos:int = 0;
         var node:TTNode = this.m_root;
         this.m_matchedStrings = [];
         if(str == null || str == "")
         {
            return;
         }
         str = str.toUpperCase();
         while(node != null)
         {
            cmp = str.charCodeAt(pos) - node.m_char;
            if(cmp < 0)
            {
               node = node.m_left;
            }
            else if(cmp > 0)
            {
               node = node.m_right;
            }
            else
            {
               if(pos + 1 == str.length && node.m_wordEnd != null)
               {
                  this.addToResultStrings(node);
               }
               node = node.m_center;
               if(++pos == str.length)
               {
                  break;
               }
            }
         }
         if(node != null)
         {
            this.walkTree(node,str);
         }
      }
      
      private function walkTree(node:TTNode, str:String) : void
      {
         if(node.m_wordEnd != null)
         {
            this.addToResultStrings(node);
         }
         if(node.m_left)
         {
            this.walkTree(node.m_left,str);
         }
         if(node.m_right)
         {
            this.walkTree(node.m_right,str);
         }
         if(node.m_center)
         {
            str += String.fromCharCode(node.m_char);
            this.walkTree(node.m_center,str);
         }
      }
      
      private function addToResultStrings(node:TTNode) : void
      {
         var result:String = null;
         if(node.m_wordEnd != null)
         {
            for each(result in node.m_wordEnd)
            {
               this.m_matchedStrings.push(result);
            }
         }
      }
      
      public function contains(str:String) : Boolean
      {
         var cmp:int = 0;
         var result:Boolean = false;
         if(str == null || str == "")
         {
            return false;
         }
         var pos:int = 0;
         var node:TTNode = this.m_root;
         while(node != null)
         {
            cmp = str.charCodeAt(pos) - node.m_char;
            if(cmp < 0)
            {
               node = node.m_left;
            }
            else if(cmp > 0)
            {
               node = node.m_right;
            }
            else
            {
               if(++pos == str.length)
               {
                  result = node.m_wordEnd != null;
                  break;
               }
               node = node.m_center;
            }
         }
         return result;
      }
   }
}

