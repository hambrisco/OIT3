import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/evaluacion.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _evaluaciones =
      FirebaseFirestore.instance.collection('evaluaciones');

  // Crear nueva evaluación
  Future<void> crearEvaluacion(Evaluacion evaluacion) async {
    await _evaluaciones.add(evaluacion.toMap());
  }

  // Obtener stream de evaluaciones
  Stream<List<Evaluacion>> obtenerEvaluaciones() {
    return _evaluaciones.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Evaluacion.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Marcar como completada/pendiente
  Future<void> toggleCompletada(String id, bool isDone) async {
    await _evaluaciones.doc(id).update({'isDone': isDone});
  }

  // Eliminar evaluación
  Future<void> eliminarEvaluacion(String id) async {
    await _evaluaciones.doc(id).delete();
  }

  // Consultar películas
  Future<Map<String, dynamic>> queryMovies(Map<String, dynamic> query) async {
    try {
      QuerySnapshot moviesSnapshot;

      if (query['titleInput'] != null) {
        moviesSnapshot = await _firestore
            .collection('movies')
            .where('title', isEqualTo: query['titleInput'])
            .get();
      } else if (query['genre'] != null) {
        moviesSnapshot = await _firestore
            .collection('movies')
            .where('genre', isEqualTo: query['genre'])
            .get();
      } else {
        moviesSnapshot = await _firestore.collection('movies').get();
      }

      final movies = moviesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'genre': data['genre'],
          'imageUrl': data['imageUrl'] ?? '',
        };
      }).toList();

      return {'movies': movies};
    } catch (e) {
      throw Exception('Error al consultar películas: $e');
    }
  }

  Future<Map<String, dynamic>> queryUsers(Map<String, dynamic> query) async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      final users = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'username': data['username'] ?? '',
        };
      }).toList();

      return {'users': users};
    } catch (e) {
      throw Exception('Error al consultar usuarios: $e');
    }
  }

  Future<Map<String, dynamic>> queryUserReviews(
      Map<String, dynamic> query) async {
    try {
      final userSnapshot =
          await _firestore.collection('users').doc(query['userId']).get();

      if (!userSnapshot.exists) {
        return {'user': null};
      }

      final userData = userSnapshot.data()!;
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userSnapshot.id)
          .get();

      final reviews =
          await Future.wait(reviewsSnapshot.docs.map((reviewDoc) async {
        final reviewData = reviewDoc.data();
        final movieDoc = await _firestore
            .collection('movies')
            .doc(reviewData['movieId'] as String)
            .get();
        final movieData = movieDoc.data()!;

        return {
          'rating': reviewData['rating'],
          'reviewDate': reviewData['reviewDate'].toDate().toIso8601String(),
          'reviewText': reviewData['reviewText'],
          'movie': {
            'id': movieDoc.id,
            'title': movieData['title'],
          }
        };
      }));

      return {
        'user': {
          'id': userSnapshot.id,
          'username': userData['username'],
          'reviews': reviews,
        }
      };
    } catch (e) {
      throw Exception('Error al consultar reseñas del usuario: $e');
    }
  }

  Future<Map<String, dynamic>> createMovie(Map<String, dynamic> movie) async {
    try {
      final docRef = await _firestore.collection('movies').add({
        'title': movie['title'],
        'genre': movie['genre'],
        'imageUrl': movie['imageUrl'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'movie_insert': {
          'id': docRef.id,
        }
      };
    } catch (e) {
      throw Exception('Error al crear película: $e');
    }
  }

  Future<Map<String, dynamic>> upsertUser(Map<String, dynamic> user) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: user['username'])
          .get();

      String userId;
      if (userQuery.docs.isEmpty) {
        final docRef = await _firestore.collection('users').add({
          'username': user['username'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        userId = docRef.id;
      } else {
        userId = userQuery.docs.first.id;
      }

      return {
        'user_insert': {
          'id': userId,
        }
      };
    } catch (e) {
      throw Exception('Error al crear/actualizar usuario: $e');
    }
  }

  Future<Map<String, dynamic>> addReview(Map<String, dynamic> review) async {
    try {
      if (!await _firestore
          .collection('movies')
          .doc(review['movieId'])
          .get()
          .then((doc) => doc.exists)) {
        throw Exception('La película no existe');
      }

      final docRef = await _firestore.collection('reviews').add({
        'movieId': review['movieId'],
        'rating': review['rating'],
        'reviewText': review['reviewText'],
        'reviewDate': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      return {
        'review_insert': {
          'id': docRef.id,
        }
      };
    } catch (e) {
      throw Exception('Error al añadir reseña: $e');
    }
  }

  Future<Map<String, dynamic>> deleteReview(Map<String, dynamic> query) async {
    try {
      final reviewQuery = await _firestore
          .collection('reviews')
          .where('movieId', isEqualTo: query['movieId'])
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (reviewQuery.docs.isEmpty) {
        throw Exception('No se encontró la reseña');
      }

      await reviewQuery.docs.first.reference.delete();

      return {
        'success': true,
      };
    } catch (e) {
      throw Exception('Error al eliminar reseña: $e');
    }
  }
}
